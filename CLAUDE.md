# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Jot** is a minimal macOS utility app. When launched, it presents a single floating pill-shaped text input bar with no window chrome that overlays all other apps. The user types text (e.g. to transcribe something unselectable on screen), presses Enter, and the text is copied to the clipboard — then the app quits. Escape also quits without copying.

## Build & Run

Requires Xcode and [xcodegen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen   # one-time setup

make open               # generate Xcode project and open it (preferred dev workflow)
make generate           # regenerate Xot.xcodeproj from project.yml without opening
make build              # build from CLI (Debug)
make clean              # remove Jot.xcodeproj and DerivedData
```

Run the app from Xcode with ⌘R. There is no test suite.

## Architecture

Three source files in `Sources/Jot/`:

| File | Role |
|---|---|
| `main.swift` | Entry point — sets `.accessory` activation policy (hides Dock icon), creates `AppDelegate` |
| `AppDelegate.swift` | Creates the `NSPanel` and positions it centered on screen |
| `InputBar.swift` | The pill-shaped view + text field + Enter/Escape handling |

**Key design choices:**
- `NSPanel` with `.floating` window level + `.canJoinAllSpaces` collection behavior keeps it above all apps on every Space
- `LSUIElement = true` in `project.yml` (written to `Info.plist` by xcodegen) suppresses the Dock icon and app switcher entry
- `InputBar` subclasses `NSVisualEffectView` directly (not a wrapper) so `hudWindow` material + `behindWindow` blending fills the full rounded pill
- The Xcode project is **generated** from `project.yml` via xcodegen — edit `project.yml`, not the `.xcodeproj`

## Assets

- `assets/jot-app-logo.png` — source app icon (needs to be converted to an `.icns` or `AppIcon.appiconset` to wire up in Xcode)
