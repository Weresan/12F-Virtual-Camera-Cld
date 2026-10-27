import XCTest
import CoreGraphics
@testable import PairingCore

final class CompositionGuideTests: XCTestCase {
    func testFittedCameraRectExcludesLetterbox() {
        let rect = CompositionGeometry.fittedRect(image:CGSize(width:1920,height:1080),container:CGSize(width:1000,height:1000))
        XCTAssertEqual(rect.width,1000,accuracy:0.00001)
        XCTAssertEqual(rect.height,562.5,accuracy:0.00001)
        XCTAssertEqual(rect.minY,218.75,accuracy:0.00001)
        XCTAssertEqual(CompositionGeometry.lines(.thirds,in:rect).count,4)
        for line in CompositionGeometry.lines(.thirds,in:rect) {
            XCTAssertGreaterThanOrEqual(line.start.y,rect.minY)
            XCTAssertLessThanOrEqual(line.end.y,rect.maxY)
        }
    }
    func testGuideOptionsAndInvalidImage() {
        let rect = CGRect(x:0,y:0,width:100,height:100)
        XCTAssertTrue(CompositionGeometry.lines(.none,in:rect).isEmpty)
        XCTAssertEqual(CompositionGeometry.lines(.safe,in:rect).count,8)
        XCTAssertEqual(CompositionGeometry.lines(.center,in:rect).count,2)
        XCTAssertEqual(CompositionGeometry.lines(.golden,in:rect)[0].start.x,38.196601125,accuracy:0.00001)
        XCTAssertEqual(CompositionGeometry.fittedRect(image:.zero,container:rect.size),.zero)
    }
}
