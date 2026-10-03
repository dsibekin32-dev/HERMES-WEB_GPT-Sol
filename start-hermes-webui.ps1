$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$env:HERMES_HOME = Join-Path $root 'state'
$env:HERMES_WEBUI_STATE_DIR = Join-Path $env:HERMES_HOME 'webui'
$env:HERMES_WEBUI_AGENT_DIR = Join-Path $root 'hermes-agent-main'
$env:HERMES_WEBUI_PYTHON = Join-Path $root 'venv\Scripts\python.exe'
$env:HERMES_WEBUI_DEFAULT_WORKSPACE = Join-Path $root 'workspace'
$env:HERMES_WEBUI_HOST = '127.0.0.1'
$env:HERMES_WEBUI_PORT = '8787'
$env:HERMES_WEBUI_PASSWORD = (Get-Content -LiteralPath (Join-Path $env:HERMES_HOME 'webui_password.txt') -Raw).Trim()
$env:TEMP = Join-Path $root 'tmp'
$env:TMP = $env:TEMP
& $env:HERMES_WEBUI_PYTHON (Join-Path $root 'hermes-webui-master\server.py')
