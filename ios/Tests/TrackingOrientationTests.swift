import XCTest
@testable import PairingCore

final class TrackingOrientationTests: XCTestCase {
    func testPortraitScanAndLandscapeSettling() {
        var gate = TrackingOrientation()
        XCTAssertFalse(gate.update(side: 0, time: 1).ready)
        XCTAssertFalse(gate.update(side: 1, time: 2).ready)
        XCTAssertFalse(gate.update(side: 1, time: 2.49).ready)
        let result = gate.update(side: 1, time: 2.5)
        XCTAssertTrue(result.ready); XCTAssertTrue(result.recalibrate)
        XCTAssertFalse(gate.update(side: 1, time: 3).recalibrate)
        XCTAssertFalse(gate.update(side: 0, time: 4).ready)
        XCTAssertFalse(gate.update(side: 2, time: 5).ready)
        XCTAssertTrue(gate.update(side: 2, time: 5.5).recalibrate)
    }

    func testUnstableSidesCannotCalibrate() {
        var gate = TrackingOrientation()
        XCTAssertFalse(gate.update(side: 1, time: 1).ready)
        XCTAssertFalse(gate.update(side: 2, time: 1.3).ready)
        XCTAssertFalse(gate.update(side: 1, time: 1.6).ready)
        XCTAssertFalse(gate.update(side: 1, time: 1.9).ready)
    }
}
