struct NativeTypeRegistry: Sendable {
    let map: [EntityTypeId: Codable.Type]

    func getTypeById(_ id: EntityTypeId) -> Codable.Type? {
        map[id]
    }
}
