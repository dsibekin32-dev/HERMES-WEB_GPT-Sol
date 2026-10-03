$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$cli = 'C:\Program Files\Tailscale\tailscale.exe'
& $cli funnel --bg 8787 *>&1 | Out-File -LiteralPath (Join-Path $root 'state\tailscale-funnel-setup.txt') -Encoding utf8
& $cli funnel status *>&1 | Out-File -LiteralPath (Join-Path $root 'state\tailscale-funnel.txt') -Encoding utf8
