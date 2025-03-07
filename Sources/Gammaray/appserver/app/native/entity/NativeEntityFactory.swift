struct NativeEntityFactory: EntityFactory {
    private let entityType: Codable.Type
    private let entityFuncs: [String: EntityFunc<Any, Any>]
    private let lib: Lib
    private let responseSender: ResponseSender
    private let jsonEncoder: StringJSONEncoder
    private let jsonDecoder: StringJSONDecoder

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
