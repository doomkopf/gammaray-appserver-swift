protocol EntityFactory: Sendable {
    func create(appId: AppId, typeId: EntityTypeId, id: EntityId, databaseEntity: String?)
        async throws -> Entity
}
