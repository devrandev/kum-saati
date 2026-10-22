import AppKit
import XCTest

final class CircleInteractionTests: XCTestCase {
    @MainActor func testClickRegionsAndSeeking() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let suite = "KumSaatiInteractionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer {
            try? FileManager.default.removeItem(at: directory)
            defaults.removePersistentDomain(forName: suite)
        }
        let model = TimerModel(directory: directory, defaults: defaults, schedulesTimers: false, uptime: { 0 })
        let view = CircleView(model: model)
        view.frame = NSRect(x: 0, y: 0, width: 220, height: 220)
        func event(_ type: NSEvent.EventType, _ point: NSPoint, clicks: Int = 1) -> NSEvent {
            NSEvent.mouseEvent(with: type, location: point, modifierFlags: [], timestamp: 0,
                               windowNumber: 0, context: nil, eventNumber: 0, clickCount: clicks, pressure: 0)!
        }
        let center = NSPoint(x: 110, y: 110)
        let edge = NSPoint(x: 110, y: 205)
        let handle = NSPoint(x: 179, y: 41)
        model.toggle()
        view.mouseDown(with: event(.leftMouseDown, edge))
        view.mouseUp(with: event(.leftMouseUp, edge))
        XCTAssertTrue(model.running, "Kenara tek tık sayacı durdurmamalı")
        view.mouseDown(with: event(.leftMouseDown, edge, clicks: 2))
        XCTAssertTrue(model.running, "Kenara çift tık sayacı değiştirmemeli")
        view.mouseDown(with: event(.leftMouseDown, handle, clicks: 2))
        XCTAssertTrue(model.running, "Tutamaçta çift tık sayacı değiştirmemeli")
        view.mouseDown(with: event(.leftMouseDown, center, clicks: 2))
        XCTAssertFalse(model.running, "Merkezde çift tık duraklatmalı")
        view.mouseDown(with: event(.leftMouseDown, center, clicks: 2))
        XCTAssertTrue(model.running, "Merkezde çift tık devam ettirmeli")
        view.mouseDown(with: event(.leftMouseDown, edge))
        view.mouseDragged(with: event(.leftMouseDragged, NSPoint(x: 115, y: 205)))
        XCTAssertTrue(!model.running && model.progress > 0, "Gerçek sarma duraklatıp süreyi değiştirmeli")
        view.mouseUp(with: event(.leftMouseUp, edge))
    }
}
