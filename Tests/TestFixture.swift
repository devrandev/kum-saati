import Foundation

@MainActor
final class TestFixture {
    let directory: URL
    let defaults: UserDefaults
    let suite: String
    var clock: TimeInterval = 0

    init() throws {
        suite = "KumSaatiTests.\(UUID().uuidString)"
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(suite)
        defaults = UserDefaults(suiteName: suite)!
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
    func makeModel() -> TimerModel {
        TimerModel(directory: directory, defaults: defaults, schedulesTimers: false, uptime: { [weak self] in self?.clock ?? 0 })
    }
    func cleanUp() {
        try? FileManager.default.removeItem(at: directory)
        defaults.removePersistentDomain(forName: suite)
    }
}
