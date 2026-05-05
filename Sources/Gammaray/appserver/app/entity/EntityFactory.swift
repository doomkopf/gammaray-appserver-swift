protocol EntityFactory: Sendable {
    func create(appId: AppId, typeId: EntityTypeId, id: EntityId, databaseEntity: JSON?)
        async throws -> Entity
}
