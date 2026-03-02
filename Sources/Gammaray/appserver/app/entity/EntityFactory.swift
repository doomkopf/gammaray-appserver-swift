protocol EntityFactory: Sendable {
    func create(appId: String, typeId: EntityTypeId, id: EntityId, databaseEntity: String?)
        async throws -> Entity
}
