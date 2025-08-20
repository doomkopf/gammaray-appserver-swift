import XCTest

@testable import Gammaray

final class EntityIdImplTest: XCTestCase {
    func testGenerated() {
        XCTAssertTrue(
            (try Regex(
                "^[0-9a-f]{8}-[0-9a-f]{4}-[4][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
            ).wholeMatch(in: EntityId().value)) != nil)
    }

    func testGeneratedIsValid() throws {
        let generated = EntityId()
        _ = try EntityId(generated.value)
    }

    func testValidAndInvalid() {
        var minLength = "123"
        var maxLength =
            "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678912345678"

        assertValid(minLength)
        assertValid(maxLength)

        minLength.removeLast()
        assertInvalid(minLength)
        maxLength.append("0")
        assertInvalid(maxLength)

        assertValid("cb1e0ff2-9f1c-4301-9390-02231bb16c67")

        assertInvalid("test&test")
    }

    private func assertValid(_ value: String) {
        do {
            _ = try EntityId(value)
        } catch {
            XCTFail("Expected to be valid, but invalid: \(value)")
        }
    }

    private func assertInvalid(_ value: String) {
        do {
            _ = try EntityId(value)
        } catch {
            return
        }

        XCTFail("Expected to be invalid, but valid: \(value)")
    }
}
