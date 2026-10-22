import AppKit

@MainActor
final class SystemActivityMonitor: NSObject {
    private let onInactive: () -> Void
    private var observers: [NSObjectProtocol] = []
    private var started = false
    private let workspaceCenter: NotificationCenter
    private let distributedCenter: DistributedNotificationCenter

    init(onInactive: @escaping () -> Void) {
        self.onInactive = onInactive
        workspaceCenter = NSWorkspace.shared.notificationCenter
        distributedCenter = .default()
        super.init()
    }
    func start() {
        guard !started else { return }
        started = true
        for name in [NSWorkspace.willSleepNotification, NSWorkspace.screensDidSleepNotification, NSWorkspace.sessionDidResignActiveNotification] {
            observers.append(workspaceCenter.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.onInactive() }
            })
        }
        distributedCenter.addObserver(self, selector: #selector(screenLocked), name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
    }
    func stop() {
        observers.forEach { workspaceCenter.removeObserver($0) }
        observers.removeAll()
        distributedCenter.removeObserver(self)
        started = false
    }
    @objc private func screenLocked() { onInactive() }
    deinit {
        for observer in observers { workspaceCenter.removeObserver(observer) }
        distributedCenter.removeObserver(self)
    }
}
