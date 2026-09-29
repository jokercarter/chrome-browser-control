[CmdletBinding()]
param(
    [string]$ChromeExe,
    [string]$SourceUserData,
    [string]$DebugUserData,
    [string]$ProfileDirectory = 'Default',
    [int]$DebugPort = 9223
)

$ErrorActionPreference = 'Stop'

if (-not $ChromeExe) { $ChromeExe = Join-Path ${env:ProgramFiles} 'Google\Chrome\Application\chrome.exe' }
if (-not $SourceUserData) { $SourceUserData = Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data' }
if (-not $DebugUserData) { $DebugUserData = Join-Path $env:LOCALAPPDATA 'CodexChromeData2' }
$sourceProfile = Join-Path $SourceUserData $ProfileDirectory
$debugProfile = Join-Path $DebugUserData $ProfileDirectory

if (-not (Test-Path -LiteralPath $ChromeExe)) { throw "Chrome executable not found: $ChromeExe" }
if (-not (Test-Path -LiteralPath $sourceProfile)) { throw "Chrome profile not found: $sourceProfile" }

$running = Get-CimInstance Win32_Process -Filter "Name = 'chrome.exe'" | Where-Object { $_.CommandLine -notmatch '--type=' }
if ($running) {
    throw 'Chrome is already running. Close Chrome normally, then run this launcher again so the debug flags apply.'
}

if (-not (Test-Path -LiteralPath $debugUserData)) {
    New-Item -ItemType Directory -Path $debugUserData -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $sourceUserData 'Local State') -Destination (Join-Path $debugUserData 'Local State') -Force
}

if (-not (Test-Path -LiteralPath $debugProfile)) {
    New-Item -ItemType Junction -Path $debugProfile -Target $sourceProfile | Out-Null
}

Start-Process -FilePath $chromeExe -ArgumentList @(
    "--user-data-dir=$debugUserData",
    "--profile-directory=$ProfileDirectory",
    "--remote-debugging-port=$DebugPort",
    '--remote-allow-origins=*',
    '--restore-last-session',
    '--no-first-run',
    '--no-default-browser-check'
) -WindowStyle Hidden
