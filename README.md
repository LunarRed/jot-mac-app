# Jot

A dead-simple macOS utility for transcribing text you can't copy — unselectable UI text, on-screen content, video, photos. Launch it, type, press Return. Done.

## What it does

Jot appears as a floating pill-shaped input bar above every window and space. Type whatever you need, then:

| Key | Action |
|---|---|
| `Return` | Copy text to clipboard and quit |
| `⇧ Return` | Insert a newline (multi-line support) |
| `Esc` | Quit without copying |

The bar expands vertically as you type multiple lines. It quits automatically if it loses focus.

## Build

Requires Xcode and [xcodegen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen
make open        # generates Jot.xcodeproj and opens Xcode
```

Then press `⌘R` in Xcode to build and run.

```bash
make build       # build from CLI (Debug)
make clean       # remove generated project and build artifacts
```

## Project structure

```
project.yml          # xcodegen spec — edit this, not Jot.xcodeproj
Sources/Jot/
  main.swift         # entry point
  AppDelegate.swift  # NSPanel setup
  InputBar.swift     # text input view + keyboard handling
assets/
  jot-app-logo.png   # source app icon
```
