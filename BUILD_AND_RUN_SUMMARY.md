# Build / Run Summary

## What was created

A macOS clipboard history app named **openclip** as a Swift Package executable app under this folder.

## Main behaviors

- Menu bar utility app
- Clipboard monitoring with persistence
- Searchable picker window
- Global hotkey: `⌘⌥V`
- Restore + attempt auto-paste
- Retention controls for count, age, and total bytes
- Support for text, URL, and image clipboard items

## Build status

Verified successfully with:

```bash
cd openclip
swift build
```

## Run status

Smoke-tested launch with:

```bash
cd openclip
swift run openclip
```

The process started and stayed running as an accessory-style menu bar app until manually terminated.

## Important runtime note

Auto-paste requires macOS Accessibility permission for the built app/process.
