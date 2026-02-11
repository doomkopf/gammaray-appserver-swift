import XCTest

@testable import Gammaray

final class StringJSONEncoderTest: XCTestCase {
    struct SomeStruct: Encodable {
        let name: String
    }

    func testEncodeStruct() {
        let encoder = StringJSONEncoder()
        let str = encoder.encode(SomeStruct(name: "test"))

        XCTAssertEqual("{\"name\":\"test\"}", str)
    }

    func testEncodeString() async throws {
        let encoder = StringJSONEncoder()
        let str = encoder.encode("someString")

        XCTAssertEqual("someString", str)
    }
}
