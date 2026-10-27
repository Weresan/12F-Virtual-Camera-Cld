import XCTest
@testable import PairingCore

final class PairingEndpointTests: XCTestCase {
    let token = String(repeating: "a", count: 43)
    func testTrustedURL() throws {
        let endpoint = try PairingEndpoint("https://192.168.1.10:8765/#token=\(token)")
        XCTAssertEqual(endpoint.socketURL.absoluteString, "wss://192.168.1.10:8765/ws")
        XCTAssertNil(URLComponents(url: endpoint.socketURL, resolvingAgainstBaseURL: false)?.fragment)
        XCTAssertEqual(endpoint.token, token)
    }
    func testInvalidAndForeignQRs() {
        for url in ["hello", "https://127.0.0.1/#token=\(token)",
                    "https://host/#token=short", "https://user:pass@host/#token=\(token)",
                    "https://host/?token=\(token)", "https://host/#token=\(token)&token=\(token)"] {
            XCTAssertThrowsError(try PairingEndpoint(url))
        }
    }
    func testHTTPRequiresExplicitDevelopmentOptIn() throws {
        let url = "http://192.168.1.10:8765/#token=\(token)"
        XCTAssertThrowsError(try PairingEndpoint(url))
        #if DEBUG
        XCTAssertEqual(try PairingEndpoint(url, allowInsecureLAN: true).socketURL.scheme,"ws")
        #else
        XCTAssertThrowsError(try PairingEndpoint(url, allowInsecureLAN: true))
        #endif
        XCTAssertThrowsError(try PairingEndpoint("http://example.com/#token=\(token)", allowInsecureLAN: true))
    }
}
