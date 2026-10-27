import XCTest
@testable import PairingCore

final class TrackingOrientationTests: XCTestCase {
    func testTapRequiredInPortraitAndLandscape() {
        for side in 1...4 {
            var gate = TrackingOrientation()
            XCTAssertFalse(gate.update(normal: true).ready)
            XCTAssertTrue(gate.activate(side: side))
            let result = gate.update(normal: true)
            XCTAssertTrue(result.ready); XCTAssertTrue(result.recalibrate)
            XCTAssertEqual(gate.side, side)
            XCTAssertFalse(gate.update(normal: true).recalibrate)
        }
    }
    func testLossRequiresAnotherTapAndInvalidBasisRejected() {
        var gate = TrackingOrientation()
        XCTAssertFalse(gate.activate(side: 0))
        XCTAssertTrue(gate.activate(side: 3))
        XCTAssertFalse(gate.update(normal: false).ready)
        XCTAssertFalse(gate.update(normal: true).ready)
        XCTAssertNil(gate.side)
        XCTAssertTrue(gate.activate(side: 2))
        XCTAssertTrue(gate.update(normal: true).recalibrate)
    }
}
