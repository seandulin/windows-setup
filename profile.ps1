# PowerShell profile — equivalent of .zshrc
# Lives at $PROFILE (run `$PROFILE` to see the exact path).
# PS7 and PS5 have SEPARATE profile files — this one is written for pwsh (PS7).

# ---- Node version manager (nvm equivalent) --------------------------------
# Using nvm-windows (CoreyButler.NVMforWindows) since it's the closest match
# to nvm's own UX. nvm-windows manages its own PATH, nothing to source here.
# If you'd rather use fnm instead (faster, more nvm-like `.nvmrc` auto-switching):
#   winget install Schniz.fnm
#   fnm env --use-on-cd | Out-String | Invoke-Expression

# ---- Prompt theme (agnoster equivalent) -----------------------------------
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\agnoster.omp.json" | Invoke-Expression
}

# ---- Better history / completion (colored-man-pages / colorize equivalent) -
Import-Module PSReadLine -ErrorAction SilentlyContinue
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -Colors @{
    Command   = 'Cyan'
    Parameter = 'Gray'
    String    = 'Yellow'
}

# ---- git status in prompt (git plugin equivalent) --------------------------
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

# ---- bat as a nicer `cat` (matches your Brewfile's bat install) -----------
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat
}

$env:DEFAULT_USER = $env:USERNAME
