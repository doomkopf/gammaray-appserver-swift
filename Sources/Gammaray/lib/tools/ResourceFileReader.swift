import Foundation

protocol ResourceFileReader: Sendable {
    func readStringFile(name: String, ext: String) throws -> String
}

final class ResourceFileReaderImpl: ResourceFileReader {
    private let module: Bundle

    init(module: Bundle) {
        self.module = module
    }

    func readStringFile(name: String, ext: String) throws -> String {
        guard
            let resourceUrl = module.url(
                forResource: name,
                withExtension: ext)
        else {
            throw AppserverError.General("Failed to locate file: \(name).\(ext)")
        }

        return try String(contentsOf: resourceUrl)
    }
}
