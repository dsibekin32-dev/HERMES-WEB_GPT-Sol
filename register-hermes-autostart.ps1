$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = Join-Path $root 'ensure-hermes-webui.ps1'
$user = $env:USERNAME
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $script + '"')
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName 'HermesWebUI' -Action $action -Trigger $trigger -Principal $principal -Description 'Start local Hermes WebUI at user sign-in' -Force | Out-Null
Get-ScheduledTask -TaskName 'HermesWebUI' | Select-Object TaskName, State | Out-File -LiteralPath (Join-Path $root 'state\autostart-status.txt') -Encoding utf8
