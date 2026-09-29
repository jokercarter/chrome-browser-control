# Chrome Browser Control Resource Bundle

This folder is a portable Windows bundle for the `chrome-browser-control` Skill.

It connects Codex to the user's existing Chrome Profile through Chrome DevTools MCP on port `9223` and supports:

- existing tab listing and page verification;
- mouse clicks, coordinate clicks, and drags;
- keyboard input and key chords;
- page screenshots for visual inspection;
- a persistent launcher that keeps the logged-in Profile data.

## Files

- `SKILL.md`: Codex Skill instructions.
- `agents/openai.yaml`: Skill UI metadata.
- `references/setup-and-recovery.md`: setup and failure recovery.
- `scripts/start_chrome_for_codex.ps1`: persistent Chrome launcher.
- `config/chrome-devtools-mcp.toml`: the MCP server block used in the user's global Codex config.
- `evidence/chrome-baidu-current.jpg`: screenshot captured from the verified Chrome session.

## Install for another Windows user

1. Copy this folder into `%USERPROFILE%\.codex\skills\chrome-browser-control` or add a Junction from that Skill path to this folder.
2. Copy the block from `config/chrome-devtools-mcp.toml` into `%USERPROFILE%\.codex\config.toml`.
3. Close Chrome normally, then run `scripts/start_chrome_for_codex.ps1`. It creates a non-default debug User Data root and links the selected Profile directory to the original Chrome Profile.
4. Start a new Codex session and invoke `$chrome-browser-control`.

The launcher accepts `-ChromeExe`, `-SourceUserData`, `-DebugUserData`, `-ProfileDirectory`, and `-DebugPort`. Example:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\start_chrome_for_codex.ps1 `
  -ProfileDirectory 'Profile 1' -DebugPort 9224
```

If a user wants a desktop shortcut, run `scripts/install-shortcut.ps1` after copying the bundle. The shortcut points to the bundle's launcher and does not contain credentials.

## MCP interfaces

The configured server exposes the following main interfaces:

| Tool | Use |
| --- | --- |
| `list_pages` | List current tabs with page IDs, titles, and URLs. |
| `take_snapshot` | Read the current page's accessibility tree and element UIDs. |
| `take_screenshot` | Return a visual screenshot of the webpage viewport. |
| `click` | Click an element by the latest snapshot UID. |
| `click_at` | Click at viewport coordinates; enabled by `--experimental-vision=true`. |
| `drag` | Drag from one snapshot element to another. |
| `fill` / `type_text` | Enter text into a visible input. |
| `press_key` | Send a key or chord such as `Enter`, `Escape`, or `Control+A`. |
| `new_page` / `navigate_page` | Open or navigate pages in the connected Chrome. |

Use the latest snapshot or screenshot before coordinate and element actions, then verify the changed URL, title, or visible text.

The package captures webpage viewports. It does not capture the Windows desktop frame or Chrome's tab bar. Video screencast tools require ffmpeg and are intentionally not enabled by default.

## Privacy and sharing

This bundle contains instructions and configuration only. It does not contain API keys, passwords, cookies, browser databases, or authorization tokens. The `evidence` image is an optional public Baidu search example and can be deleted before sharing.

The launcher links a local Chrome Profile directory at runtime. Never copy the resulting `CodexChromeData2` directory or the original Chrome User Data directory to another person. Each user should run the launcher on their own machine and choose their own Profile directory.
