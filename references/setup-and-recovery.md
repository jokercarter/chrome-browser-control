# Setup and recovery

This reference describes the portable Windows setup. Read it when the normal browser workflow cannot connect.

## Verify the working path

Check that the current Chrome process includes the debug profile and port:

```powershell
Get-CimInstance Win32_Process -Filter "Name = 'chrome.exe'" |
  Where-Object { $_.CommandLine -notmatch '--type=' } |
  Select-Object ProcessId, CommandLine

Invoke-RestMethod http://127.0.0.1:9223/json/version
```

The main process should contain `--user-data-dir=%LOCALAPPDATA%\CodexChromeData2` and `--remote-debugging-port=9223`. The endpoint should report Chrome and a `webSocketDebuggerUrl`.

Check the profile link without reading cookies:

```powershell
Get-Item "$env:LOCALAPPDATA\CodexChromeData2\Default" -Force |
  Select-Object FullName, LinkType, Target
```

The `Default` entry should be a Junction targeting the original Chrome `Default` directory. Never print cookie databases or cookie values.

## Start or restart

Run the launcher from the Skill folder. Replace the profile or port arguments when needed:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
  "$env:USERPROFILE\.codex\skills\chrome-browser-control\scripts\start_chrome_for_codex.ps1"
```

Supported parameters include `-ChromeExe`, `-SourceUserData`, `-DebugUserData`, `-ProfileDirectory`, and `-DebugPort`.

The launcher stops with an error when Chrome is already running. Close Chrome normally before retrying. This prevents two Chrome processes from writing the same Profile.

## MCP configuration

Copy the portable MCP block from `config/chrome-devtools-mcp.toml` into the user's Codex config. It is equivalent to:

```toml
[mcp_servers.chrome-devtools]
command = "npx"
args = [
  "-y",
  "chrome-devtools-mcp@latest",
  "--browser-url=http://127.0.0.1:9223",
  "--experimental-vision=true",
  "--screenshot-format=jpeg",
  "--screenshot-max-width=1600",
  "--screenshot-max-height=1000",
  "--no-usage-statistics",
]
startup_timeout_ms = 20000
```

`--experimental-vision=true` exposes coordinate tools such as `click_at`. The screenshot options limit image size for the model. `take_screenshot` works without ffmpeg; the optional screencast tools require ffmpeg and are not part of the working setup.

## Failure cleanup

If an experimental method is abandoned, remove its temporary processes and files, but keep the working launcher, the selected profile Junction, port `9223`, and this MCP configuration. Do not remove the user's original Chrome User Data directory.

Useful process check:

```powershell
Get-CimInstance Win32_Process |
  Where-Object { $_.CommandLine -match 'chrome-devtools-mcp|mcp_.*test' } |
  Select-Object ProcessId, Name, CommandLine
```

Only terminate helper processes created for the failed test. Do not terminate `chrome.exe` unless the user has authorized a Chrome restart and the launcher will be used to reopen the Profile.



