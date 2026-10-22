import AppKit
import Combine

@MainActor
protocol CircleViewWindowDelegate: AnyObject {
    func beginWindowDrag()
    func moveWindow(by delta: NSSize)
    func resizeWindow(by delta: NSSize)
    func endWindowDrag()
}

@MainActor
final class CircleView: NSView {
    weak var windowDelegate: CircleViewWindowDelegate?
    private let model: TimerModel
    private var observation: AnyCancellable?
    private var hovered = false
    private enum DragMode { case move, seek, resize }
    private var dragMode: DragMode?
    private var didBeginSeek = false
    private var initialMouse = NSPoint.zero
    private var seekProgress = 0.0
    private var previousAngle = 0.0
    private var tracking: NSTrackingArea?
    private var disk: NSRect { bounds.insetBy(dx: CircleStyle.inset, dy: CircleStyle.inset) }
    private var resizeRect: NSRect {
        let radius = disk.width / 2
        let center = NSPoint(x: bounds.midX + radius * 0.7071, y: bounds.midY - radius * 0.7071)
        return NSRect(x: center.x - CircleStyle.handleHitSize / 2, y: center.y - CircleStyle.handleHitSize / 2, width: CircleStyle.handleHitSize, height: CircleStyle.handleHitSize)
    }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(resizeRect, cursor: .crosshair)
    }

    init(model: TimerModel) {
        self.model = model
        super.init(frame: .zero)
        observation = model.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async { self?.needsDisplay = true }
        }
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(L10n.circleAccessibility)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let tracking { removeTrackingArea(tracking) }
        let area = NSTrackingArea(rect: .zero, options: [.activeAlways, .mouseEnteredAndExited, .inVisibleRect], owner: self)
        addTrackingArea(area); tracking = area
    }
    override func mouseEntered(with event: NSEvent) { hovered = true; needsDisplay = true }
    override func mouseExited(with event: NSEvent) { hovered = false; needsDisplay = true }
    override func hitTest(_ point: NSPoint) -> NSView? {
        let local = convert(point, from: superview)
        let center = NSPoint(x: bounds.midX, y: bounds.midY)
        return hypot(local.x - center.x, local.y - center.y) <= disk.width / 2 || resizeRect.contains(local) ? self : nil
    }
    override func draw(_ dirtyRect: NSRect) {
        drawBackground()
        drawProgress()
        if hovered {
            drawRoundCount()
            drawResizeHandle()
        }
    }
    private func drawBackground() {
        CircleStyle.background.setFill()
        NSBezierPath(ovalIn: disk).fill()
    }
    private func drawProgress() {
        let fraction = model.progress
        guard fraction > 0 else { return }
        (model.running ? CircleStyle.running : CircleStyle.stopped).setFill()
        if fraction >= 1 {
            NSBezierPath(ovalIn: disk).fill()
            return
        }
        let center = NSPoint(x: bounds.midX, y: bounds.midY)
        let path = NSBezierPath()
        path.move(to: center)
        path.line(to: NSPoint(x: center.x, y: disk.maxY))
        path.appendArc(withCenter: center, radius: disk.width / 2, startAngle: 90, endAngle: 90 - 360 * fraction, clockwise: true)
        path.close()
        path.fill()
    }
    private func drawRoundCount() {
        let text = L10n.roundCount(model.count) as NSString
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: max(CircleStyle.minimumFontSize, disk.width * CircleStyle.fontScale), weight: .medium),
            .foregroundColor: NSColor.white,
            .shadow: textShadow()
        ]
        let size = text.size(withAttributes: attrs)
        text.draw(at: NSPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2), withAttributes: attrs)
    }
    private func drawResizeHandle() {
        let center = NSPoint(x: resizeRect.midX, y: resizeRect.midY)
        let radius = CircleStyle.handleBadgeSize / 2
        CircleStyle.handleBackground.setFill()
        NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)).fill()
        CircleStyle.handleStroke.setStroke()
        let path = NSBezierPath()
        path.lineWidth = CircleStyle.handleLineWidth
        let arm = CircleStyle.handleArrowSize / 2
        path.move(to: NSPoint(x: center.x - arm, y: center.y + arm))
        path.line(to: NSPoint(x: center.x + arm, y: center.y - arm))
        path.move(to: NSPoint(x: center.x, y: center.y - arm))
        path.line(to: NSPoint(x: center.x + arm, y: center.y - arm))
        path.line(to: NSPoint(x: center.x + arm, y: center.y))
        path.move(to: NSPoint(x: center.x - arm, y: center.y))
        path.line(to: NSPoint(x: center.x - arm, y: center.y + arm))
        path.line(to: NSPoint(x: center.x, y: center.y + arm))
        path.stroke()
    }
    private func textShadow() -> NSShadow {
        let shadow = NSShadow(); shadow.shadowColor = NSColor.black.withAlphaComponent(0.55); shadow.shadowBlurRadius = 3
        return shadow
    }
    private func angle(at point: NSPoint) -> Double {
        let raw = atan2(point.x - bounds.midX, point.y - bounds.midY) / (2 * .pi)
        return raw < 0 ? raw + 1 : raw
    }
    private func region(at point: NSPoint) -> DragMode? {
        if resizeRect.contains(point) { return .resize }
        let distance = hypot(point.x - bounds.midX, point.y - bounds.midY)
        guard distance <= disk.width / 2 else { return nil }
        return distance > disk.width / 2 - CircleStyle.seekBandWidth ? .seek : .move
    }
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        dragMode = region(at: point)
        didBeginSeek = false
        if event.clickCount == 2 {
            if dragMode == .move { model.toggle() }
            dragMode = nil
            return
        }
        guard dragMode != nil else { return }
        initialMouse = NSEvent.mouseLocation
        previousAngle = angle(at: point)
        windowDelegate?.beginWindowDrag()
    }
    override func mouseDragged(with event: NSEvent) {
        guard let dragMode else { return }
        let mouse = NSEvent.mouseLocation
        let delta = NSSize(width: mouse.x - initialMouse.x, height: mouse.y - initialMouse.y)
        switch dragMode {
        case .move:
            windowDelegate?.moveWindow(by: delta)
        case .resize:
            windowDelegate?.resizeWindow(by: delta)
        case .seek:
            // Tek tık sayacı etkilemez; yalnızca gerçek sarma hareketi duraklatır.
            let point = convert(event.locationInWindow, from: nil)
            if !didBeginSeek {
                let currentAngle = angle(at: point)
                let arcDistance = abs(wrappedDelta(currentAngle - previousAngle)) * 2 * .pi * disk.width / 2
                guard arcDistance >= CircleStyle.dragThreshold else { return }
                model.pause()
                seekProgress = model.progress
                didBeginSeek = true
            }
            let nextAngle = angle(at: point)
            seekProgress = min(1, max(0, seekProgress + wrappedDelta(nextAngle - previousAngle)))
            previousAngle = nextAngle
            model.seek(to: seekProgress)
        }
    }
    private func wrappedDelta(_ delta: Double) -> Double {
        if delta > 0.5 { return delta - 1 }
        if delta < -0.5 { return delta + 1 }
        return delta
    }
    override func mouseUp(with event: NSEvent) {
        windowDelegate?.endWindowDrag()
        dragMode = nil
        didBeginSeek = false
    }
}
