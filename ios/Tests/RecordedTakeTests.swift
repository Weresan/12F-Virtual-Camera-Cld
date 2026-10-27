import XCTest
@testable import PairingCore

final class RecordedTakeTests: XCTestCase {
    func testCatalogMatchesProtocol() throws {
        let data = #"[{"id":"take-1","label":"Shot A","start":10,"end":70,"fps":30.0}]"#.data(using:.utf8)!
        let take = try JSONDecoder().decode([RecordedTake].self,from:data)[0]
        XCTAssertEqual(take.id,"take-1")
        XCTAssertEqual(take.duration,2)
        XCTAssertEqual(try JSONDecoder().decode(RecordedTake.self,from:JSONEncoder().encode(take)),take)
    }
}
