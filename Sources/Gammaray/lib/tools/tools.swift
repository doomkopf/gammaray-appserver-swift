import Foundation

func currentTimeMillis() -> Int64 {
    Int64(Date().timeIntervalSince1970) * 1000
}

func readStringFile(name: String, ext: String, module: Bundle) throws -> String {
    guard
        let resourceUrl = module.url(
            forResource: name,
            withExtension: ext)
    else {
        throw AppserverError.General("Failed to locate file: \(name).\(ext)")
    }

    return try String(contentsOf: resourceUrl)
}
