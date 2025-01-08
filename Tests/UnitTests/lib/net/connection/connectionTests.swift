import XCTest

@testable import Gammaray

final class connectionTests: XCTestCase {
    func testStringToTerminatedBuffer() throws {
        let buf = stringToTerminatedBuffer("teøst")

        XCTAssertEqual(buf.readableBytes, 7)
        XCTAssertEqual(buf.getNullTerminatedString(at: 0), "teøst")
    }
}
