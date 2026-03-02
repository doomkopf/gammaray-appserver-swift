actor NativeEntityFactory: EntityFactory {
    private let entityTypes: [EntityTypeId: EntityType]
    private let libContainer: LibContainer
    private let responseSender: ResponseSender
    private let jsonEncoder: StringJSONEncoder
    private let jsonDecoder: StringJSONDecoder
    private let typeRegistry: NativeTypeRegistry

    init(
        entityTypes: [EntityTypeId: EntityType],
        libContainer: LibContainer,
        responseSender: ResponseSender,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder,
        typeRegistry: NativeTypeRegistry,
    ) {
        self.entityTypes = entityTypes
        self.libContainer = libContainer
        self.responseSender = responseSender
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.typeRegistry = typeRegistry
    }

    func create(appId: String, typeId: EntityTypeId, id: EntityId, databaseEntity: String?)
        async throws
        -> Entity
    {
        guard let entityType = entityTypes[typeId] else {
            throw AppError.General("Entity type has no functions: \(typeId)")
        }

        let lib = try await libContainer.get()
        return try NativeEntity(
            entityFuncs: entityType.efunc,
            id: id,
            lib: lib,
            responseSender: responseSender,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder,
            typeRegistry: typeRegistry,
            entityTypeId: typeId,
            databaseEntity: databaseEntity,
        )
    }
}
