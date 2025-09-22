actor NativeEntityFactory: EntityFactory {
    private let entityType: Codable.Type
    private let entityFuncs: [String: EntityFunc]
    private let libFactory: LibFactory
    private let responseSender: ResponseSender
    private let jsonEncoder: StringJSONEncoder
    private let jsonDecoder: StringJSONDecoder

    init(
        entityType: Codable.Type,
        entityFuncs: [String: EntityFunc],
        libFactory: LibFactory,
        responseSender: ResponseSender,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder,
    ) {
        self.entityType = entityType
        self.entityFuncs = entityFuncs
        self.libFactory = libFactory
        self.responseSender = responseSender
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func create(appId: String, type: String, id: EntityId, databaseEntity: String?) async throws
        -> Entity
    {
        let lib = try await libFactory.create()
        return try NativeEntity(
            entityFuncs: entityFuncs,
            id: id,
            lib: lib,
            responseSender: responseSender,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder,
            entityType: entityType,
            databaseEntity: databaseEntity,
        )
    }
}
