import XCTest

@testable import Gammaray

final class ConfigTest: XCTestCase {
    func testConfiguredAndDefaultValue() throws {
        final class ResourceFileReaderMock: ResourceFileReader {
            private let content: String

            init(_ content: String) {
                self.content = content
            }

            func readStringFile(name: String, ext: String) throws -> String {
                content
            }
        }

        let readerWithEmptyFile = ResourceFileReaderMock("")
        let configExpectedToUseDefaultValue = try Config(
            reader: readerWithEmptyFile, customConfig: [:])
        XCTAssertEqual(
            "dummyDefaultValue", configExpectedToUseDefaultValue.getString(ConfigProperty.dummy))

        let readerWithContent = ResourceFileReaderMock(
            "dummy=the=dummyValue\nnodeJsBinaryPath=some/path\n")
        let configExpectedToUseConfiguredValue = try Config(
            reader: readerWithContent, customConfig: [:])
        XCTAssertEqual(
            "the=dummyValue", configExpectedToUseConfiguredValue.getString(ConfigProperty.dummy))
        XCTAssertEqual(
            "some/path",
            configExpectedToUseConfiguredValue.getString(ConfigProperty.nodeJsBinaryPath))
        XCTAssertEqual(
            4000,
            configExpectedToUseConfiguredValue.getInt(
                ConfigProperty.nodeJsAppApiRequestTimeoutMillis))
    }
}
