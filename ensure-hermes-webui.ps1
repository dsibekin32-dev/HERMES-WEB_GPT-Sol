$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
try {
    $response = Invoke-WebRequest -Uri 'http://127.0.0.1:8787/api/auth/status' -TimeoutSec 3
    if ($response.StatusCode -eq 200) { return }
} catch {
    # Start the local server when it is not already listening.
}
Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $root 'start-hermes-webui.ps1')) -WorkingDirectory $root -WindowStyle Hidden
