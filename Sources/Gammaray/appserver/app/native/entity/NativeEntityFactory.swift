actor NativeEntityFactory: EntityFactory {
    private let entityTypeFuncs: [String: [String: EntityFunc]]
    private let libFactory: LibFactory
    private let responseSender: ResponseSender
    private let jsonEncoder: StringJSONEncoder
    private let jsonDecoder: StringJSONDecoder
    private let typeRegistry: NativeTypeRegistry

    init(
        entityTypeFuncs: [String: [String: EntityFunc]],
        libFactory: LibFactory,
        responseSender: ResponseSender,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder,
        typeRegistry: NativeTypeRegistry,
    ) {
        self.entityTypeFuncs = entityTypeFuncs
        self.libFactory = libFactory
        self.responseSender = responseSender
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.typeRegistry = typeRegistry
    }

    func create(appId: String, type: String, id: EntityId, databaseEntity: String?) async throws
        -> Entity
    {
        guard let entityFuncs = entityTypeFuncs[type] else {
            throw AppError.General("Entity type has no functions: \(type)")
        }

        let lib = try await libFactory.create()
        return try NativeEntity(
            entityFuncs: entityFuncs,
            id: id,
            lib: lib,
            responseSender: responseSender,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder,
            typeRegistry: typeRegistry,
            entityType: type,
            databaseEntity: databaseEntity,
        )
    }
}
