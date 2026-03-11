import AppKit

/// The floating pill-shaped input bar.
final class InputBar: NSView {
    private let textView    = NSTextView()
    private let placeholder = NSTextField(labelWithString: "Jot something…")
    private let hintLabel   = NSTextField(labelWithString: "↵ copy · ⇧↵ newline · esc quit")

    private let hPadding:     CGFloat = 24
    private let topPadding:   CGFloat = 14
    private let botPadding:   CGFloat = 10
    private let hintHeight:   CGFloat = 16
    private let textGap:      CGFloat = 6
    private let cornerRadius: CGFloat = 16

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        layer?.cornerRadius = cornerRadius
        layer?.masksToBounds = true
        setupTextView()
        setupPlaceholder()
        setupHintLabel()
        layoutContent(size: frame.size)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupTextView() {
        textView.font = .systemFont(ofSize: 18)
        textView.textColor = .labelColor
        textView.isRichText = false
        textView.drawsBackground = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.focusRingType = .none
        textView.textContainerInset = .zero
        textView.textContainer?.lineFragmentPadding = 0
        textView.delegate = self
        addSubview(textView)
    }

    private func setupPlaceholder() {
        placeholder.font = .systemFont(ofSize: 18)
        placeholder.textColor = .placeholderTextColor
        placeholder.isEditable = false
        placeholder.isSelectable = false
        placeholder.drawsBackground = false
        placeholder.isBordered = false
        addSubview(placeholder)
    }

    private func setupHintLabel() {
        hintLabel.font = .systemFont(ofSize: 11)
        hintLabel.textColor = .tertiaryLabelColor
        hintLabel.isEditable = false
        hintLabel.isSelectable = false
        hintLabel.drawsBackground = false
        hintLabel.isBordered = false
        hintLabel.alignment = .right
        addSubview(hintLabel)
    }

    // MARK: - Layout

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        guard !subviews.isEmpty else { return }
        layoutContent(size: newSize)
    }

    private func layoutContent(size: NSSize) {
        let availWidth = size.width - hPadding * 2
        let textOriginY = botPadding + hintHeight + textGap
        let textHeight = max(size.height - textOriginY - topPadding, 24)
        let textFrame = NSRect(x: hPadding, y: textOriginY, width: availWidth, height: textHeight)

        hintLabel.frame  = NSRect(x: hPadding, y: botPadding, width: availWidth, height: hintHeight)
        textView.frame   = textFrame
        placeholder.frame = textFrame
        textView.textContainer?.containerSize = NSSize(width: availWidth, height: .greatestFiniteMagnitude)
    }

    // MARK: - Public

    func focus() {
        window?.makeFirstResponder(textView)
    }

    // MARK: - Private

    private func updateWindowHeight() {
        guard let lm = textView.layoutManager,
              let tc = textView.textContainer,
              let window = window else { return }

        lm.ensureLayout(for: tc)
        let usedTextHeight = lm.usedRect(for: tc).height

        let textOriginY = botPadding + hintHeight + textGap
        let needed = ceil(textOriginY + max(usedTextHeight, 24) + topPadding)
        guard abs(window.frame.height - needed) > 0.5 else { return }

        let f = window.frame
        window.setFrame(
            NSRect(x: f.minX, y: f.maxY - needed, width: f.width, height: needed),
            display: true, animate: false
        )
    }
}

// MARK: - NSTextViewDelegate

extension InputBar: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        placeholder.isHidden = !textView.string.isEmpty
        updateWindowHeight()
    }

    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.insertNewline(_:)):
            if NSEvent.modifierFlags.contains(.shift) {
                textView.insertNewlineIgnoringFieldEditor(nil)
                return true
            }
            let text = textView.string.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            }
            NSApp.terminate(nil)
            return true

        case #selector(NSResponder.cancelOperation(_:)):
            NSApp.terminate(nil)
            return true

        default:
            return false
        }
    }
}
