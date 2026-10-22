import XCTest

final class TimerModelTests: XCTestCase {
    @MainActor func testProgressAndPauseResume() async throws {
        let fixture = try TestFixture()
        defer { fixture.cleanUp() }
        let model = fixture.makeModel()
        model.setDuration(minutes: 25)
        XCTAssertFalse(model.running)
        model.toggle()
        fixture.clock = 750
        model.tick()
        XCTAssertEqual(model.progress, 0.5, accuracy: 0.0001)
        model.pause()
        fixture.clock += 1000
        model.tick()
        XCTAssertEqual(model.progress, 0.5, accuracy: 0.0001)
        model.toggle()
        fixture.clock += 750
        model.tick()
        XCTAssertTrue(model.finished)
        XCTAssertFalse(model.running)
        XCTAssertEqual(model.rounds.count, 1)
        model.tick()
        XCTAssertEqual(model.rounds.count, 1)
    }
    @MainActor func testManuallyAdjustedRoundDoesNotCount() async throws {
        let fixture = try TestFixture()
        defer { fixture.cleanUp() }
        let model = fixture.makeModel()
        model.setDuration(minutes: 25)
        model.seek(to: 0.9)
        model.toggle()
        fixture.clock += 151
        model.tick()
        XCTAssertTrue(model.finished)
        XCTAssertTrue(model.rounds.isEmpty)
        model.toggle()
        fixture.clock += 1500
        model.tick()
        XCTAssertEqual(model.rounds.count, 1, "Yeni tur elle sarma işaretini sıfırlamalı")
    }
    @MainActor func testReopeningPreservesHistoryButResetsCurrentRound() async throws {
        let fixture = try TestFixture()
        defer { fixture.cleanUp() }
        let model = fixture.makeModel()
        model.setDuration(minutes: 1)
        model.toggle()
        fixture.clock += 60
        model.tick()
        let reopened = fixture.makeModel()
        XCTAssertEqual(reopened.rounds.count, 1)
        XCTAssertEqual(reopened.elapsed, 0)
        XCTAssertFalse(reopened.running)
        XCTAssertEqual(reopened.duration, 60)
    }
    @MainActor func testNonfiniteInputsAreIgnored() async throws {
        let fixture = try TestFixture()
        defer { fixture.cleanUp() }
        let model = fixture.makeModel()
        model.setDuration(minutes: 25)
        model.setDuration(minutes: .nan)
        model.seek(to: .infinity)
        XCTAssertEqual(model.duration, 1500)
        XCTAssertEqual(model.elapsed, 0)
    }
}
