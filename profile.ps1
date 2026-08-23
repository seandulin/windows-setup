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

# PS5's bundled PSReadLine (2.0.0) doesn't have -PredictionSource / -PredictionViewStyle
# — those need PSReadLine 2.1+. This guards so the same profile works on both PS5 and PS7.
$psrl = Get-Module PSReadLine
if ($psrl -and $psrl.Version -ge [version]'2.1.0') {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView
}
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
# The built-in 'cat' alias is flagged AllScope, which Set-Alias can't strip —
# passing -Option AllScope here keeps that flag intact while overwriting the
# target, which is what actually lets this succeed instead of erroring.
if (Get-Command bat -ErrorAction SilentlyContinue) {
    try {
        Set-Alias -Name cat -Value bat -Option AllScope -Force -ErrorAction Stop
    } catch {
        Write-Warning "Could not alias `'cat`' to bat in this shell - run `'bat`' directly instead."
    }
}

$env:DEFAULT_USER = $env:USERNAME