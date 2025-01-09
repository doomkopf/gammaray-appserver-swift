import XCTest

@testable import Gammaray

final class ConfigTest: XCTestCase {
    func testConfiguredAndDefaultValue() throws {
        class ResourceFileReaderMock: ResourceFileReader {
            private let content: String

            init(_ content: String) {
                self.content = content
            }

            func readStringFile(name: String, ext: String) throws -> String {
                content
            }
        }

        let readerWithEmptyFile = ResourceFileReaderMock("")
        let configExpectedToUseDefaultValue = try Config(reader: readerWithEmptyFile)
        XCTAssertEqual(
            "dummyDefaultValue", configExpectedToUseDefaultValue.get(ConfigProperty.dummy))

        let readerWithContent = ResourceFileReaderMock(
            "dummy=the=dummyValue\nnodeJsBinaryPath=some/path\n")
        let configExpectedToUseConfiguredValue = try Config(reader: readerWithContent)
        XCTAssertEqual(
            "the=dummyValue", configExpectedToUseConfiguredValue.get(ConfigProperty.dummy))
        XCTAssertEqual(
            "some/path",
            configExpectedToUseConfiguredValue.get(ConfigProperty.nodeJsBinaryPath))
    }
}
