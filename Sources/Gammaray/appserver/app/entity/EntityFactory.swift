protocol EntityFactory: Sendable {
    func create(appId: String, type: EntityTypeId, id: EntityId, databaseEntity: String?)
        async throws -> Entity
}
