struct NativeEntityFactory: EntityFactory {
    let entityType: Codable.Type
    let entityFuncs: [String: EntityFunc<Any, Any>]
    let libFactory: LibFactory
    let responseSender: ResponseSender
    let jsonEncoder: StringJSONEncoder
    let jsonDecoder: StringJSONDecoder

    func create(appId: String, type: String, id: EntityId, databaseEntity: String?) async throws
        -> Entity
    {
        var entity: Codable?
        if let databaseEntity {
            entity = try jsonDecoder.decode(entityType, databaseEntity)
        }
        let lib = try await libFactory.create()
        return NativeEntity(
            entityFuncs: entityFuncs,
            id: id,
            lib: lib,
            responseSender: responseSender,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder,
            entity: entity
        )
    }
}
