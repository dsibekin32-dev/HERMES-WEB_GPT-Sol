$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$serverPath = Join-Path $root 'hermes-webui-master\server.py'
$launcherPath = Join-Path $root 'start-hermes-webui.ps1'
$pidFile = Join-Path $root 'state\webui.pid'

$servers = Get-CimInstance Win32_Process | Where-Object {
    $_.CommandLine -and $_.CommandLine.Contains($serverPath)
}
foreach ($server in $servers) {
    Stop-Process -Id $server.ProcessId -ErrorAction Stop
}

if (Test-Path -LiteralPath $pidFile) {
    $launcherPid = [int](Get-Content -LiteralPath $pidFile -Raw)
    $launcher = Get-CimInstance Win32_Process -Filter "ProcessId = $launcherPid"
    if ($launcher -and $launcher.CommandLine -and $launcher.CommandLine.Contains($launcherPath)) {
        Stop-Process -Id $launcherPid -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $pidFile
}
Write-Host "Hermes WebUI остановлен; процессов: $(@($servers).Count)."
