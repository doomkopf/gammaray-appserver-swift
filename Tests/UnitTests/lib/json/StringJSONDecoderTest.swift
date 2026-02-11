import XCTest

@testable import Gammaray

final class StringJSONDecoderTest: XCTestCase {
    struct SomeStruct: Decodable {
        let name: String
        let age: Int
    }

    func testDecodeStruct() throws {
        let decoder = StringJSONDecoder()
        let obj = try decoder.decode(SomeStruct.self, "{\"name\":\"test\",\"age\":42}")

        XCTAssertEqual("test", obj.name)
        XCTAssertEqual(42, obj.age)
    }

    func testDecodeString() async throws {
        let decoder = StringJSONDecoder()
        let str = try decoder.decode(String.self, "someString")

        XCTAssertEqual("someString", str)
    }
}
