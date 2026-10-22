import XCTest

final class PersistenceTests: XCTestCase {
    @MainActor func testLegacyFilterMigration() async throws {
        let fixture = try TestFixture()
        defer { fixture.cleanUp() }
        fixture.defaults.set("Son 15 saat", forKey: "historyFilter")
        let settings = TimerSettings(defaults: fixture.defaults)
        XCTAssertEqual(settings.filter, .fifteen)
        XCTAssertEqual(fixture.defaults.string(forKey: "historyFilter"), "last15Hours")
        settings.filter = .tenDays
        XCTAssertEqual(TimerSettings(defaults: fixture.defaults).filter, .tenDays)
    }
    @MainActor func testRetentionAndRoundTrip() async throws {
        let fixture = try TestFixture()
        defer { fixture.cleanUp() }
        let store = RoundHistoryStore(directory: fixture.directory)
        _ = try store.load()
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let rounds = [CompletedRound(date: now.addingTimeInterval(-61 * 86400), duration: 60),
                      CompletedRound(date: now.addingTimeInterval(-60 * 86400), duration: 120),
                      CompletedRound(date: now, duration: 1500)]
        let retained = store.retained(rounds, at: now)
        XCTAssertEqual(retained.count, 2)
        try store.save(retained)
        let loaded = try RoundHistoryStore(directory: fixture.directory).load()
        XCTAssertEqual(loaded.map(\.id), retained.map(\.id))
        XCTAssertEqual(loaded.map(\.duration), [120, 1500])
    }
    @MainActor func testCorruptedHistoryIsNotOverwritten() async throws {
        let fixture = try TestFixture()
        defer { fixture.cleanUp() }
        let store = RoundHistoryStore(directory: fixture.directory)
        let original = Data("invalid-json".utf8)
        try original.write(to: store.fileURL)
        XCTAssertThrowsError(try store.load())
        XCTAssertFalse(store.canWrite)
        try store.save([])
        let preserved = try Data(contentsOf: store.fileURL)
        XCTAssertEqual(preserved, original)
    }
    @MainActor func testModelPrunesHistoryOnOpen() async throws {
        let fixture = try TestFixture()
        defer { fixture.cleanUp() }
        let store = RoundHistoryStore(directory: fixture.directory)
        _ = try store.load()
        try store.save([CompletedRound(date: Date().addingTimeInterval(-61 * 86400), duration: 60),
                        CompletedRound(date: Date(), duration: 60)])
        let model = fixture.makeModel()
        XCTAssertEqual(model.rounds.count, 1)
        XCTAssertEqual(try store.load().count, 1)
    }
}
