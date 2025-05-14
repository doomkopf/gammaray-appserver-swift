protocol EntityFactory: Sendable {
    func create(appId: String, type: String, id: EntityId, databaseEntity: String?) async throws
        -> Entity
}
