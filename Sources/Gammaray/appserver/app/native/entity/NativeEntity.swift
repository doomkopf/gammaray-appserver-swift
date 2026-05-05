actor NativeEntity: Entity {
    private let log: Logger
    private let entityFuncs: [FunctionName: EntityFunc]
    private let id: EntityId
    private let lib: Lib
    private let responseSender: ResponseSender
    private let jsonEncoder: StringJSONEncoder
    private let jsonDecoder: StringJSONDecoder
    private let typeRegistry: NativeTypeRegistry

    private var entity: Codable?

    init(
        loggerFactory: LoggerFactory,
        entityFuncs: [FunctionName: EntityFunc],
        id: EntityId,
        lib: Lib,
        responseSender: ResponseSender,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder,
        typeRegistry: NativeTypeRegistry,
        entityTypeId: EntityTypeId,
        databaseEntity: JSON?,
    ) throws {
        log = loggerFactory.createForClass(NativeEntity.self)
        self.entityFuncs = entityFuncs
        self.id = id
        self.lib = lib
        self.responseSender = responseSender
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.typeRegistry = typeRegistry

        if let databaseEntity {
            guard let type = typeRegistry.getTypeById(entityTypeId) else {
                throw AppserverError.General(
                    "No native type registered for entity type: \(entityTypeId)")
            }
            entity = try jsonDecoder.decode(type, databaseEntity.buildString())
        }
    }

    func invokeFunction(theFunc: FunctionName, payload: String?, ctx: RequestContext) throws
        -> EntityAction
    {
        guard let entityFunc = entityFuncs[theFunc] else {
            return .none
        }

        var decodedPayload: Decodable?
        if let payload, let payloadType = entityFunc.payloadType {
            decodedPayload = try jsonDecoder.decode(payloadType, payload)
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

        if case .setEntity(let e) = result {
            entity = e
        }

        return map(result)
    }

    func toJSON() async -> JSON? {
        guard let entity else {
            return nil
        }

        do {
            return try JSON.fromString(jsonEncoder.encode(entity))
        } catch {
            log.log(.ERROR, "Error parsing JSON from string", error)
            return nil
        }
    }

    private func map(_ result: EntityFuncResult) -> EntityAction {
        switch result {
        case .none: return .none
        case .setEntity: return .setEntity
        case .deleteEntity: return .deleteEntity
        }
    }
}
