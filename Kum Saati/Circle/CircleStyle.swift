import AppKit

enum CircleStyle {
    static let inset: CGFloat = 12
    static let minimumSize: CGFloat = 100
    static let maximumSize: CGFloat = 600
    static let defaultSize: CGFloat = 220
    static let handleHitSize: CGFloat = 36
    static let handleBadgeSize: CGFloat = 22
    static let handleArrowSize: CGFloat = 10
    static let handleLineWidth: CGFloat = 1.5
    static let seekBandWidth: CGFloat = 18
    static let dragThreshold: CGFloat = 3
    static let minimumFontSize: CGFloat = 12
    static let fontScale: CGFloat = 0.09
    static let background = NSColor.black.withAlphaComponent(0.10)
    static let running = NSColor(srgbRed: 0.19, green: 0.79, blue: 0.40, alpha: 0.90)
    static let stopped = NSColor(srgbRed: 0.95, green: 0.68, blue: 0.20, alpha: 0.90)
    static let handleBackground = NSColor.black.withAlphaComponent(0.65)
    static let handleStroke = NSColor.white.withAlphaComponent(0.9)
}
