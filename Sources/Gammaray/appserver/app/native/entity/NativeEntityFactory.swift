struct NativeEntityFactory: EntityFactory {
    let entityType: Codable.Type
    let entityFuncs: [String: EntityFunc<Any, Any>]
    let lib: Lib
    let responseSender: ResponseSender
    let jsonEncoder: StringJSONEncoder
    let jsonDecoder: StringJSONDecoder

    func create(appId: String, type: String, id: EntityId, databaseEntity: String?) throws -> Entity
    {
        var entity: Codable?
        if let databaseEntity {
            entity = try jsonDecoder.decode(entityType, databaseEntity)
        }
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
