protocol Database: Sendable {
    func get(_ key: String) async -> String?
    func put(_ key: String, _ value: String) async
    func remove(_ key: String) async
    func shutdown() async
}
