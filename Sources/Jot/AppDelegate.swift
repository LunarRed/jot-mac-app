import AppKit

/// NSPanel subclass so we can unconditionally accept key window status.
/// A plain borderless NSPanel can return false for canBecomeKey depending on
/// its style mask, which silently prevents keyboard input.
private final class JotPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: JotPanel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let width: CGFloat = 640
        let height: CGFloat = 72

        panel = JotPanel(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.center()

        panel.contentView = InputBar(frame: NSRect(x: 0, y: 0, width: width, height: height))

        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            (self.panel.contentView as? InputBar)?.focus()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(panelDidResignKey),
            name: NSWindow.didResignKeyNotification,
            object: panel
        )

        setupMenu()
    }

    @objc private func panelDidResignKey() {
        NSApp.terminate(nil)
    }

    /// Builds a hidden main menu so Cmd+A/C/V/X/Z key equivalents resolve
    /// correctly. The menu bar is invisible (LSUIElement app) but AppKit still
    /// routes key equivalents through NSApp.mainMenu before the responder chain.
    private func setupMenu() {
        let menu = NSMenu()

        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        appItem.submenu = appMenu
        menu.addItem(appItem)

        let editItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)),  keyEquivalent: "a"))
        editMenu.addItem(NSMenuItem(title: "Cut",        action: #selector(NSText.cut(_:)),        keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "Copy",       action: #selector(NSText.copy(_:)),       keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "Paste",      action: #selector(NSText.paste(_:)),      keyEquivalent: "v"))
        editMenu.addItem(.separator())
        editMenu.addItem(NSMenuItem(title: "Undo",       action: #selector(UndoManager.undo),      keyEquivalent: "z"))
        editMenu.addItem(NSMenuItem(title: "Redo",       action: #selector(UndoManager.redo),      keyEquivalent: "Z"))
        editItem.submenu = editMenu
        menu.addItem(editItem)

        NSApp.mainMenu = menu
    }
}
