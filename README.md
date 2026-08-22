# Windows setup — Brewfile / dotfiles equivalent

Mirrors your Mac `init.sh` + `install.sh` + Brewfile flow. Windows 10, PowerShell 7.

## Install order

Same two-step shape as your Mac flow (`init.sh` then `install.sh`):

```powershell
# 1. One-time bootstrap: registry prefs, dirs, ssh, git config, Windows Terminal, PS profile
.\init.ps1

# 2. Everything else — packages, fonts, terminal theme, in one shot
.\install.ps1
```

`install.ps1` is the orchestrator (your `install.sh` equivalent) — it runs `winget import` against `packages.json`, launches Windows Terminal once so its `settings.json` exists to edit, applies the color scheme, then installs the fonts. You don't need to call `apply-terminal-theme.ps1` or `install-fonts.ps1` yourself; `install.ps1` calls both.

Expect a handful of UAC prompts along the way — some winget packages (Docker Desktop especially) elevate themselves mid-install. Just approve them as they pop.

After it finishes, close and reopen the terminal once so PATH picks up everything winget just installed — then `oh-my-posh` / `fnm` / `bat` etc. from `profile.ps1` will resolve.

## Package mapping notes

Most of your Brewfile mapped cleanly to a winget ID (all in `packages.json`). A few didn't, and I didn't want to guess wrong IDs into that file — here's what to do with each:

| Brewfile item | Status | What to do instead |
|---|---|---|
| `htop` | no exact match | `winget install Clement.bottom` (closest CLI equivalent) — verify the ID with `winget search bottom` first, it's a smaller package and IDs there move around more |
| `tree` | not needed | built into `cmd.exe` already; in PowerShell, `Get-ChildItem -Recurse` covers it |
| `wakeonlan` | no package needed | see the PowerShell function below — it's a ~10-line function, not worth a dependency |
| `mas` + all `mas "..."` entries | Mac App Store CLI/apps | no Windows equivalent needed — these were only ever for the App Store |
| `sol` (Spotlight-style launcher) | covered by PowerToys | PowerToys Run (`Alt+Space`) is the closest match, included in `packages.json` |
| `rectangle` (window snapping) | covered by PowerToys | PowerToys FancyZones, plus Windows' native `Win+Arrow` snapping already does a lot of what Rectangle does |
| `maestral` | no Windows build | Maestral is macOS/Linux only. Use the official Dropbox client on Windows instead |
| `fantastical` | no Windows build | Mac/iOS only. No close equivalent — worth deciding whether Outlook or a web calendar covers what you actually use it for |
| `readdle-spark` | no Windows build (historically) | worth double-checking current status before you build a workflow around it — if it's still Mac/iOS-only, Outlook or a webmail client is the fallback |
| `whalebird` (Mastodon client) | no confirmed winget package | it is cross-platform (Electron), just grab the Windows build directly from its GitHub releases page |
| `openlogi` | unclear what this is | this one didn't resolve to anything I recognize — worth double-checking what it actually is before I guess at a Windows equivalent |
| `typewhisper` | unconfirmed winget ID | check `winget search typewhisper` yourself, or grab it from wherever you got it on Mac |
| `wifiman` | unconfirmed winget ID | try the Microsoft Store on your home machine (fine there, unlike at work) — Ubiquiti's own site is the fallback |
| `iina` | not needed | VLC (already in `packages.json`) covers this |
| MAS: Overcast, Instapaper, Instapaper Save, Whisper Transcription | iOS/Mac-only apps | no direct Windows equivalents; these are apps you'd keep using on your phone regardless |

## Wake-on-LAN function (replaces the `wakeonlan` brew formula)

Add to `profile.ps1` if you use this:

```powershell
function Send-WakeOnLan {
    param([Parameter(Mandatory)][string]$MacAddress)
    $mac = ($MacAddress -replace '[:-]', '')
    $bytes = [byte[]](,0xFF * 6)
    $bytes += ([byte[]]($mac -split '(?<=\G.{2})(?=.)' | ForEach-Object { [convert]::ToByte($_, 16) })) * 16
    $client = New-Object System.Net.Sockets.UdpClient
    $client.Connect(([System.Net.IPAddress]::Broadcast), 9)
    $client.Send($bytes, $bytes.Length) | Out-Null
    $client.Close()
}
# Usage: Send-WakeOnLan -MacAddress "AA:BB:CC:DD:EE:FF"
```

Given your homelab, you'll probably want this aliased for your Proxmox/TrueNAS boxes specifically.
