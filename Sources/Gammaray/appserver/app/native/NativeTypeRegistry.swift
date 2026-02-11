struct NativeTypeRegistry: Sendable {
    let map: [String: Codable.Type]

    func getTypeByName(_ name: String) -> Codable.Type? {
        map[name]
    }
}
