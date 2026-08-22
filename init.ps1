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

# ---- Windows Terminal ----------------------------------------------------
# Win11 ships this by default; Win10 needs it installed explicitly.
if (-not (Get-AppxPackage -Name Microsoft.WindowsTerminal -ErrorAction SilentlyContinue)) {
    winget install --id Microsoft.WindowsTerminal -e --accept-package-agreements --accept-source-agreements
}

# ---- PowerShell profile ----------------------------------------------------
# Equivalent of `cp ./.zshrc ~/.zshrc`. $PROFILE differs between PS5 and PS7 —
# this only sets up the PS7 (pwsh) profile. See profile.ps1 in this same folder.
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir | Out-Null }
Copy-Item -Path ".\profile.ps1" -Destination $PROFILE -Force
Write-Host "Copied profile.ps1 to $PROFILE"
Write-Host "Not sourcing it — you likely haven't installed oh-my-posh/fnm yet. Run packages install first."

Write-Host "`nDone. Open a new terminal, then run: winget import -i packages.json --accept-package-agreements --accept-source-agreements"
