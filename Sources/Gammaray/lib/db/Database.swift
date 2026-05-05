protocol Database: Sendable {
    func get(_ key: String) async throws -> String?
    func put(_ key: String, _ value: String) async throws
    func remove(_ key: String) async throws
    func shutdown() async
}
