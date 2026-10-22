import Foundation

@MainActor
final class TimerSettings {
    private enum Key {
        static let duration = "durationMinutes"
        static let filter = "historyFilter"
    }
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        filter = HistoryFilter.restore(defaults.string(forKey: Key.filter))
    }
    var durationMinutes: Double {
        get {
            let stored = defaults.double(forKey: Key.duration)
            guard stored.isFinite, stored > 0 else { return 60 }
            return min(1440, max(1, stored))
        }
        set {
            guard newValue.isFinite else { return }
            defaults.set(min(1440, max(1, newValue)), forKey: Key.duration)
        }
    }
    var filter: HistoryFilter {
        get { HistoryFilter.restore(defaults.string(forKey: Key.filter)) }
        set { defaults.set(newValue.rawValue, forKey: Key.filter) }
    }
}
