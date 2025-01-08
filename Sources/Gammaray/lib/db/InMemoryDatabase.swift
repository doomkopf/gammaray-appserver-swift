actor InMemoryDatabase: Database {
    private var map: [String: String] = [:]

    func get(_ key: String) async -> String? {
        map[key]
    }

    func put(_ key: String, _ value: String) async {
        map[key] = value
    }

    func remove(_ key: String) async {
        map.removeValue(forKey: key)
    }

    func shutdown() async {
    }
}
