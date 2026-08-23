<#
.SYNOPSIS
    Installs the fonts from your Brewfile's font casks (Fira Code, Fira Mono,
    Fira Mono Nerd Font, Inconsolata + powerline variants).
.NOTES
    winget does not have reliable package IDs for most of these fonts, so this
    downloads the official releases directly and installs them the way the
    Fira Code Windows install docs recommend (Shell COM install, no reboot needed).
#>

function Install-FontFile {
    param([string]$FontPath)
    $shellApp = New-Object -ComObject Shell.Application
    $fontsFolder = $shellApp.Namespace(0x14)  # CSIDL_FONTS
    $fontsFolder.CopyHere($FontPath, 0x10)    # 0x10 = no progress UI, no overwrite confirm
}

function Install-FontZip {
    param([string]$Url, [string]$Name)
    $zipPath = "$env:TEMP\$Name.zip"
    $extractPath = "$env:TEMP\$Name"
    Write-Host "Downloading $Name..."
    Invoke-WebRequest -Uri $Url -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    Get-ChildItem -Path $extractPath -Recurse -Include *.ttf, *.otf | ForEach-Object {
        Install-FontFile -FontPath $_.FullName
    }
    Remove-Item $zipPath, $extractPath -Recurse -Force
    Write-Host "Installed $Name."
}

# Fira Code — using the Nerd Fonts patched release, NOT tonsky's original repo.
# The plain FiraCode.zip release has ligatures but no icon/powerline glyphs,
# which is what causes oh-my-posh to show a broken box character instead of
# its segment icons. The Nerd Fonts version has both.
Install-FontZip -Url "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip" -Name "FiraCodeNerdFont"

# Fira Mono Nerd Font (Nerd Fonts patched release)
Install-FontZip -Url "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraMono.zip" -Name "FiraMonoNerdFont"

# Inconsolata (Google Fonts family, covers the base + "for powerline" use case
# since Nerd Fonts patched variants supersede the old powerline-specific forks)
Install-FontZip -Url "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Inconsolata.zip" -Name "InconsolataNerdFont"

Write-Host "Done. Restart any open terminal apps to see the new fonts in font pickers."
Write-Host "Note: the old `'for-powerline`' Inconsolata forks are effectively superseded by the Nerd Font patched version above - it includes the powerline glyphs plus a lot more icon coverage."