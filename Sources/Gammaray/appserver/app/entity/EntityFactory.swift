protocol EntityFactory: Sendable {
    func create(appId: String, type: String, id: EntityId, databaseEntity: String?) throws -> Entity
}
