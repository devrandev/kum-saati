import Foundation
import Combine

@MainActor
final class TimerModel: ObservableObject {
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var running = false
    @Published private(set) var duration: TimeInterval
    @Published private(set) var rounds: [CompletedRound] = []
    @Published private(set) var storageError: String?
    @Published var filter: HistoryFilter {
        didSet { settings.filter = filter }
    }
    private var lastTick: TimeInterval?
    private var timer: Timer?
    private var maintenanceTimer: Timer?
    private let settings: TimerSettings
    private let historyStore: RoundHistoryStore
    private let schedulesTimers: Bool
    var statusTitle: String {
        if finished { return L10n.completed }
        if running { return L10n.running }
        return elapsed > 0 ? L10n.paused : L10n.ready
    }
    private var manuallyAdjusted = false
    private let uptime: () -> TimeInterval
    private var lastPruned = Date()
    var progress: Double { min(1, max(0, elapsed / duration)) }
    var finished: Bool { elapsed >= duration }
    var count: Int { matchingRounds.count }
    var matchingRounds: [CompletedRound] {
        let now = Date()
        return rounds.filter { $0.date >= filter.start(at: now) && $0.date <= now }
    }

    init(directory overrideDirectory: URL? = nil, defaults: UserDefaults = .standard, schedulesTimers: Bool = true, uptime: @escaping () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }) {
        self.uptime = uptime
        let settings = TimerSettings(defaults: defaults)
        self.settings = settings
        self.historyStore = RoundHistoryStore(directory: overrideDirectory)
        self.schedulesTimers = schedulesTimers
        duration = settings.durationMinutes * 60
        filter = settings.filter
        do {
            rounds = try historyStore.load()
            pruneAndSave()
        } catch {
            storageError = L10n.historyReadError(error.localizedDescription)
        }
        if schedulesTimers {
            maintenanceTimer = Timer(timeInterval: 3600, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated { self?.pruneAndSave() }
            }
            if let maintenanceTimer { RunLoop.main.add(maintenanceTimer, forMode: .common) }
        }
    }
    deinit {
        timer?.invalidate()
        maintenanceTimer?.invalidate()
    }

    private func startTicker() {
        guard schedulesTimers, timer == nil else { return }
        let ticker = Timer(timeInterval: 1.0 / 30, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        ticker.tolerance = 0.005
        timer = ticker
        RunLoop.main.add(ticker, forMode: .common)
    }
    private func stopTicker() {
        timer?.invalidate()
        timer = nil
    }

    func toggle() {
        if running { pause() } else {
            if finished { reset() }
            running = true
            lastTick = uptime()
            startTicker()
        }
    }
    func pause() {
        tick()
        running = false
        lastTick = nil
        stopTicker()
    }

    func reset() {
        stopTicker()
        running = false
        lastTick = nil
        elapsed = 0
        manuallyAdjusted = false
    }

    func setDuration(minutes: Double) {
        guard minutes.isFinite else { return }
        reset()
        duration = min(1440, max(1, minutes)) * 60
        settings.durationMinutes = duration / 60
    }
    func seek(to fraction: Double) {
        guard fraction.isFinite else { return }
        manuallyAdjusted = true
        elapsed = min(1, max(0, fraction)) * duration
        lastTick = running ? uptime() : nil
        if finished {
            running = false
            lastTick = nil
            stopTicker()
        }
    }
    func tick() {
        if Date().timeIntervalSince(lastPruned) >= 3600 { pruneAndSave() }
        guard running, let previous = lastTick else { return }
        let now = uptime()
        lastTick = now
        elapsed = min(duration, elapsed + max(0, now - previous))
        if finished {
            running = false
            lastTick = nil
            stopTicker()
            if !manuallyAdjusted {
                rounds.append(CompletedRound(date: Date(), duration: duration))
                pruneAndSave()
            }
        }
    }
    func pruneAndSave() {
        lastPruned = Date()
        rounds = historyStore.retained(rounds, at: Date())
        guard historyStore.canWrite else { return }
        do {
            try historyStore.save(rounds)
            storageError = nil
        } catch { storageError = L10n.historyWriteError(error.localizedDescription) }
    }
}
