actor NativeEntityFactory: EntityFactory {
    private let entityTypeFuncs: [String: [String: EntityFunc]]
    private let libContainer: LibContainer
    private let responseSender: ResponseSender
    private let jsonEncoder: StringJSONEncoder
    private let jsonDecoder: StringJSONDecoder
    private let typeRegistry: NativeTypeRegistry

    init(
        entityTypeFuncs: [String: [String: EntityFunc]],
        libContainer: LibContainer,
        responseSender: ResponseSender,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder,
        typeRegistry: NativeTypeRegistry,
    ) {
        self.entityTypeFuncs = entityTypeFuncs
        self.libContainer = libContainer
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

        let lib = try await libContainer.get()
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
