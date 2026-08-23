<#
.SYNOPSIS
    Windows equivalent of init.sh — base machine setup.
.NOTES
    Run in PowerShell 7 (pwsh). Some steps need elevation (Explorer registry
    tweaks do not; icacls does not; installing Windows Terminal via winget does not).
    Run once, then open a new terminal.
#>

$ErrorActionPreference = "Stop"

# ---- Explorer prefs (Finder equivalent) ----------------------------------
$advanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $advanced -Name Hidden -Value 1          # show hidden files
Set-ItemProperty -Path $advanced -Name HideFileExt -Value 0     # show file extensions
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name FullPath -Value 1  # full path in title bar
# Note: Finder's icon-view/list-view toggle and status bar have no clean global
# registry equivalent in the Win11 Explorer redesign — set once by hand if you want it.

# ---- Directories -----------------------------------------------------------
$codeDir = "$env:USERPROFILE\Code"
if (-not (Test-Path $codeDir)) {
    New-Item -ItemType Directory -Path $codeDir | Out-Null
    Write-Host "Created $codeDir"
} else {
    Write-Host "$codeDir already exists."
}

$sshDir = "$env:USERPROFILE\.ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir | Out-Null
    Write-Host "Created $sshDir"
} else {
    Write-Host "$sshDir already exists."
}
# chmod 700 equivalent — restrict to current user only
icacls $sshDir /inheritance:r /grant:r "$($env:USERNAME):(OI)(CI)F" | Out-Null

# ---- git config --------------------------------------------------------
# Set these before running, same as $my_name / $my_email in init.sh
$my_name  = "Sean Dulin"
$my_email = "sean.dulin@gmail.com"
git config --global user.name  $my_name
git config --global user.email $my_email

# ---- WSL (Ubuntu) -----------------------------------------------------
# Requires an elevated (Run as Administrator) window the first time.
# If this machine has never had WSL installed before, Windows needs a reboot
# before Ubuntu is actually usable — just re-run this script after rebooting
# and it'll confirm Ubuntu is present rather than trying to reinstall it.
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Warning "wsl.exe not found — this Windows build may be too old for in-box WSL. Skipping."
} elseif (-not $isAdmin) {
    Write-Warning "Skipping WSL — re-run this script from an elevated ('Run as Administrator') PowerShell to install/check WSL + Ubuntu."
} else {
    # wsl.exe outputs UTF-16 with null bytes interleaved when captured like this —
    # strip them or the -match below silently fails to find "Ubuntu" even when present.
    $distros = (wsl --list --quiet 2>$null) -replace "`0", ""
    if ($distros -match "Ubuntu") {
        Write-Host "WSL Ubuntu already installed."
    } else {
        Write-Host "Installing WSL with Ubuntu (first-time install needs a reboot before it's usable)..."
        wsl --install -d Ubuntu
    }
}

# ---- Windows Terminal ----------------------------------------------------
# Win11 ships this by default; Win10 needs it installed explicitly.
# Note: NOT using Get-AppxPackage here — that cmdlet needs the Appx module,
# which is Windows PowerShell (Desktop) only and fails to load under PS7/Core.
# winget install is idempotent on its own, so just call it directly.
winget install --id Microsoft.WindowsTerminal -e --accept-package-agreements --accept-source-agreements

# ---- PowerShell profile ----------------------------------------------------
# Equivalent of `cp ./.zshrc ~/.zshrc`. PS5 and PS7 have SEPARATE profile files
# and you use both, so this installs the same profile.ps1 to each rather than
# relying on whichever $PROFILE the current shell resolves to.
$profileTargets = @()

$pwshProfile = & pwsh -NoProfile -Command '$PROFILE' 2>$null
if ($pwshProfile) { $profileTargets += $pwshProfile }

$ps5Profile = & powershell.exe -NoProfile -Command '$PROFILE' 2>$null
if ($ps5Profile) { $profileTargets += $ps5Profile }

foreach ($target in $profileTargets) {
    $dir = Split-Path $target
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item -Path ".\profile.ps1" -Destination $target -Force
    Write-Host "Copied profile.ps1 to $target"
}

# Give PS5 a modern PSReadLine too (its bundled 2.0.0 lacks prediction features
# entirely) so both shells actually get the same behavior, not just no errors.
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber -MinimumVersion 2.2.0

Write-Host "Not sourcing the profile - you likely haven't installed oh-my-posh/fnm yet. Run .\install.ps1 next."

Write-Host "`nDone. Open a new terminal, then run: winget import -i packages.json --accept-package-agreements --accept-source-agreements"