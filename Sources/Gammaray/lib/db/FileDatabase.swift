import Foundation

final class FileDatabase: Database, Sendable {
    private let path: String
    private let ext: String

    init(
        path: String,
        ext: String,
    ) {
        self.path = path
        self.ext = ext
    }

    func get(_ key: String) async throws -> String? {
        try await withCheckedThrowingContinuation { c in
            Task {
                do {
                    let str = try readFileSync(path: keyToPath(key))
                    c.resume(returning: str)
                } catch {
                    c.resume(throwing: error)
                }
            }
        }
    }

    func put(_ key: String, _ value: String) async throws {
        try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Error>) in
            Task {
                do {
                    try writeFileSync(path: keyToPath(key), content: value)
                } catch {
                    c.resume(throwing: error)
                    return
                }
                c.resume()
            }
        }
    }

    func remove(_ key: String) async throws {
        try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Error>) in
            Task {
                do {
                    try deleteFileSync(path: keyToPath(key))
                } catch {
                    c.resume(throwing: error)
                    return
                }
                c.resume()
            }
        }
    }

    func shutdown() async {
    }

    private func keyToPath(_ key: String) -> String {
        "\(self.path + key).\(self.ext)"
    }

    private func writeFileSync(path: String, content: String) throws {
        try content.write(toFile: path, atomically: true, encoding: .utf8)
    }

    private func readFileSync(path: String) throws -> String? {
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch let error as CocoaError {
            switch error.code {
            case .fileReadNoSuchFile:
                return nil
            default:
                throw error
            }
        } catch {
            throw error
        }
    }

    private func deleteFileSync(path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }
}
