import XCTest
@testable import CameoKit

final class CameoKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CameoKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
