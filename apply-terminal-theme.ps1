<#
.SYNOPSIS
    Injects tomorrow-night-eighties.json into Windows Terminal's settings.json
    and sets it as the default color scheme. Run after Windows Terminal is installed
    and has been launched at least once (so settings.json exists).
#>

$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-not (Test-Path $settingsPath)) {
    Write-Error "settings.json not found at $settingsPath. Launch Windows Terminal once first."
    exit 1
}

# Back up the existing settings before touching them
Copy-Item $settingsPath "$settingsPath.bak" -Force

$settings   = Get-Content $settingsPath -Raw | ConvertFrom-Json
$newScheme  = Get-Content ".\tomorrow-night-eighties.json" -Raw | ConvertFrom-Json

$existing = $settings.schemes | Where-Object { $_.name -eq $newScheme.name }
if ($existing) {
    Write-Host "Scheme already present, leaving as-is."
} else {
    $settings.schemes += $newScheme
}

$settings.profiles.defaults.colorScheme = $newScheme.name

# Depth 32 matters: ConvertTo-Json truncates nested objects at depth 2 by default
$settings | ConvertTo-Json -Depth 32 | Set-Content $settingsPath

Write-Host "Applied '$($newScheme.name)' as the default Windows Terminal color scheme."
Write-Host "Backup saved to $settingsPath.bak"
