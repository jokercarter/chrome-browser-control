[CmdletBinding()]
param(
    [string]$ShortcutPath = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Chrome - Codex Debug.lnk')
)

$ErrorActionPreference = 'Stop'
$launcher = Join-Path $PSScriptRoot 'start_chrome_for_codex.ps1'
if (-not (Test-Path -LiteralPath $launcher)) { throw "Launcher not found: $launcher" }

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$launcher`""
$shortcut.WorkingDirectory = Split-Path -Parent $PSScriptRoot
$shortcut.Description = 'Launch Chrome with Codex browser control, mouse, keyboard, and screenshots'
$shortcut.Save()
Write-Output $ShortcutPath
