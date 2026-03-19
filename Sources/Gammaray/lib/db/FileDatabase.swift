import Foundation

final class FileDatabase: Database, Sendable {
    private let log: Logger
    private let path: String
    private let ext: String

    init(
        loggerFactory: LoggerFactory,
        path: String,
        ext: String,
    ) {
        log = loggerFactory.createForClass(FileDatabase.self)
        self.path = path
        self.ext = ext
    }

    func get(_ key: String) async -> String? {
        await withCheckedContinuation { c in
            Task {
                c.resume(returning: readFileSync(path: keyToPath(key)))
            }
        }
    }

    func put(_ key: String, _ value: String) async {
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            Task {
                writeFileSync(path: keyToPath(key), content: value)
                c.resume()
            }
        }
    }

    func remove(_ key: String) async {
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            Task {
                deleteFileSync(path: keyToPath(key))
                c.resume()
            }
        }
    }

    func shutdown() async {
    }

    private func keyToPath(_ key: String) -> String {
        "\(self.path + key).\(self.ext)"
    }

    private func writeFileSync(path: String, content: String) {
        do {
            try content.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            log.log(.ERROR, "Error writing file", error)
        }
    }

    private func readFileSync(path: String) -> String? {
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            return nil
        }
    }

    private func deleteFileSync(path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            log.log(.ERROR, "Error deleting file", error)
        }
    }
}
