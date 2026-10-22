import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let model = TimerModel()
    private var circleController: CircleWindowController?
    private var menuController: MenuBarController?
    private var activityMonitor: SystemActivityMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let circle = CircleWindowController(model: model)
        circleController = circle
        menuController = MenuBarController(model: model, showCircle: { [weak circle] in circle?.showCircle() })
        activityMonitor = SystemActivityMonitor { [weak model] in model?.pause() }
        activityMonitor?.start()
        circle.showCircle()
    }

    func applicationWillTerminate(_ notification: Notification) {
        activityMonitor?.stop()
        menuController?.stop()
        model.pause()
        model.pruneAndSave()
    }
}
