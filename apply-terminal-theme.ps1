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

# Font face — this was the missing piece causing broken glyphs in the prompt.
# "Mono" variant is the Nerd Fonts recommendation for terminals: it keeps icon
# glyphs at a fixed cell width so the prompt doesn't drift out of alignment
# the way the proportional-width variant can.
if (-not $settings.profiles.defaults.font) {
    $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name font -Value ([PSCustomObject]@{})
}
$settings.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name face -Value "FiraCode Nerd Font Mono" -Force

# Depth 32 matters: ConvertTo-Json truncates nested objects at depth 2 by default
$settings | ConvertTo-Json -Depth 32 | Set-Content $settingsPath

Write-Host "Applied `'$($newScheme.name)`' as the default Windows Terminal color scheme."
Write-Host "Set default font to 'FiraCode Nerd Font Mono'."
Write-Host "Backup saved to $settingsPath.bak"