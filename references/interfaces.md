# Chrome control interfaces

Use the configured `chrome-devtools` MCP server after the launcher has started Chrome on port `9223`.

## Read and inspect

```text
Use $chrome-browser-control. List the current pages and report each page ID, title, and URL. Then take a screenshot of the selected page. Do not read cookies, passwords, or authorization headers.
```

Call `list_pages`, select an exact page ID, then use `take_snapshot` and `take_screenshot`.

## Mouse

```text
Use $chrome-browser-control. Take a fresh screenshot of the current page, click the visible button at the requested location, and verify the resulting page state.
```

- Prefer `click` with a current snapshot UID when the element is identifiable.
- Use `click_at` for coordinate interaction after a fresh screenshot.
- Use `drag` for element-to-element dragging. Reobserve after layout changes.

## Keyboard

```text
Use $chrome-browser-control. Focus the visible search field, type the requested text, press Enter, and verify the resulting URL and title.
```

- Use `fill` for a known input UID.
- Use `type_text` after confirming focus.
- Use `press_key` for `Enter`, `Escape`, `Tab`, and modifier chords.

## Visual verification

```text
Use $chrome-browser-control. Capture the current webpage screenshot and describe only the visible page controls and text needed for this task.
```

`take_screenshot` returns a page viewport image. It does not expose the full Windows desktop or browser tab bar. Keep screenshots and page content private when they contain logged-in data.
