import AppKit

@MainActor
final class CircleWindowController: NSWindowController, CircleViewWindowDelegate {
    private static let frameName = "KumSaatiCircle"
    private var initialFrame = NSRect.zero

    init(model: TimerModel) {
        let panel = FloatingPanel(
            contentRect: NSRect(x: 100, y: 100, width: CircleStyle.defaultSize, height: CircleStyle.defaultSize),
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false
        )
        super.init(window: panel)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = false
        panel.hidesOnDeactivate = false
        let circle = CircleView(model: model)
        circle.windowDelegate = self
        panel.contentView = circle
        panel.setFrameAutosaveName(Self.frameName)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func showCircle() {
        guard let window,
              let screen = NSScreen.screens.first(where: { $0.visibleFrame.intersects(window.frame) }) ?? NSScreen.main else { return }
        var frame = window.frame
        let visible = screen.visibleFrame
        let side = min(max(CircleStyle.minimumSize, frame.width), maximumSize(on: screen))
        frame.size = NSSize(width: side, height: side)
        frame.origin.x = min(max(frame.origin.x, visible.minX), visible.maxX - side)
        frame.origin.y = min(max(frame.origin.y, visible.minY), visible.maxY - side)
        window.setFrame(frame, display: true)
        window.orderFrontRegardless()
    }
    func beginWindowDrag() { initialFrame = window?.frame ?? .zero }
    func moveWindow(by delta: NSSize) {
        window?.setFrameOrigin(NSPoint(x: initialFrame.minX + delta.width, y: initialFrame.minY + delta.height))
    }
    func resizeWindow(by delta: NSSize) {
        guard let window else { return }
        let side = min(maximumSize(on: window.screen), max(CircleStyle.minimumSize, initialFrame.width + (delta.width - delta.height) / 2))
        window.setFrame(NSRect(x: initialFrame.minX, y: initialFrame.maxY - side, width: side, height: side), display: true)
        if let contentView = window.contentView { window.invalidateCursorRects(for: contentView) }
    }
    func endWindowDrag() { window?.saveFrame(usingName: Self.frameName) }
    private func maximumSize(on screen: NSScreen?) -> CGFloat {
        guard let visible = screen?.visibleFrame else { return CircleStyle.maximumSize }
        return min(CircleStyle.maximumSize, min(visible.width, visible.height))
    }
}

private final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
