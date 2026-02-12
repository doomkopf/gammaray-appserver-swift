actor NativeEntity: Entity {
    private let entityFuncs: [String: EntityFunc]
    private let id: EntityId
    private let lib: Lib
    private let responseSender: ResponseSender
    private let jsonEncoder: StringJSONEncoder
    private let jsonDecoder: StringJSONDecoder
    private let typeRegistry: NativeTypeRegistry

    private var entity: Codable?

    init(
        entityFuncs: [String: EntityFunc],
        id: EntityId,
        lib: Lib,
        responseSender: ResponseSender,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder,
        typeRegistry: NativeTypeRegistry,
        entityType: String,
        databaseEntity: String?,
    ) throws {
        self.entityFuncs = entityFuncs
        self.id = id
        self.lib = lib
        self.responseSender = responseSender
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.typeRegistry = typeRegistry

        if let databaseEntity {
            guard let type = typeRegistry.getTypeByName(entityType) else {
                throw AppserverError.General(
                    "No native type registered for entity type: \(entityType)")
            }
            entity = try jsonDecoder.decode(type, databaseEntity)
        }
    }

    func invokeFunction(theFunc: String, payload: String?, ctx: RequestContext) throws
        -> EntityAction
    {
        guard let entityFunc = entityFuncs[theFunc] else {
            return .none
        }

        var decodedPayload: Decodable?
        if let payload {
            decodedPayload = try jsonDecoder.decode(entityFunc.payloadType, payload)
        }

        let result = try entityFunc.f(
            entity, id, lib, decodedPayload,
            ApiRequestContextImpl(
                requestId: ctx.requestId,
                requestingUserId: ctx.requestingUserId,
                clientRequestId: ctx.clientRequestId,
                persistentSession: ctx.persistentSession,
                responseSender: responseSender
            ))

        // figure out how to do this with a single if statement
        switch result {
        case .setEntity(let e):
            entity = e
            break
        case .none:
            break
        case .deleteEntity:
            break
        }

        return map(result)
    }

    func toString() async -> String? {
        guard let entity else {
            return nil
        }

        return jsonEncoder.encode(entity)
    }

    private func map(_ result: EntityFuncResult) -> EntityAction {
        switch result {
        case .none: return .none
        case .setEntity: return .setEntity
        case .deleteEntity: return .deleteEntity
        }
    }
}
