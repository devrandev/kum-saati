import AppKit
import SwiftUI

@MainActor
final class MenuBarController: NSObject {
    private let model: TimerModel
    private let statusItem: NSStatusItem
    private let popover = NSPopover()

    init(model: TimerModel, showCircle: @escaping () -> Void) {
        self.model = model
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()
        statusItem.button?.image = NSImage(systemSymbolName: "hourglass", accessibilityDescription: L10n.appName)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView(model: model, showCircle: showCircle))
    }
    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            model.pruneAndSave()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    func stop() {
        popover.performClose(nil)
        NSStatusBar.system.removeStatusItem(statusItem)
    }
}
