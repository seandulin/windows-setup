<#
.SYNOPSIS
    Windows equivalent of install.sh — runs everything after init.ps1.
.DESCRIPTION
    1. Installs all packages from packages.json (the Brewfile equivalent)
    2. Installs fonts (the font casks equivalent)
    3. Applies the Windows Terminal color scheme (the manual iTerm2 step, now scripted)
.NOTES
    Run from this same folder, after init.ps1, in PowerShell 7:
        .\install.ps1
    Some winget packages (Docker Desktop, etc.) will pop their own UAC prompts —
    that's normal, approve them as they come.
#>

$ErrorActionPreference = "Stop"
$here = $PSScriptRoot

function Write-Step($msg) {
    Write-Host "`n=== $msg ===" -ForegroundColor Cyan
}

# ---- Sanity check: winget present ------------------------------------------
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Install 'App Installer' from the Microsoft Store first, then re-run."
    exit 1
}

# ---- 1. Packages (Brewfile equivalent) -------------------------------------
Write-Step "Installing packages from packages.json"
winget import -i (Join-Path $here "packages.json") --accept-package-agreements --accept-source-agreements --ignore-unavailable

# ---- 2. Windows Terminal settings.json must exist before we can edit it ----
# It's only created the first time Windows Terminal actually launches.
$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (-not (Test-Path $wtSettingsPath)) {
    Write-Step "Launching Windows Terminal once to generate settings.json"
    Start-Process "wt.exe"
    $tries = 0
    while (-not (Test-Path $wtSettingsPath) -and $tries -lt 20) {
        Start-Sleep -Seconds 1
        $tries++
    }
    Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 1
}

# ---- 3. Terminal color scheme (manual iTerm2 step, now scripted) -----------
Write-Step "Applying Tomorrow Night Eighties color scheme"
& (Join-Path $here "apply-terminal-theme.ps1")

# ---- 4. Fonts ---------------------------------------------------------------
Write-Step "Installing fonts"
& (Join-Path $here "install-fonts.ps1")

Write-Step "Done"
Write-Host "Open a new Windows Terminal tab to see the theme + fonts."
Write-Host "If oh-my-posh/fnm commands in your prompt aren't found yet, close and reopen the terminal once more - PATH changes from winget installs need a fresh shell."
