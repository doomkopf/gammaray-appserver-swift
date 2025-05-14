private struct ListChunk: Codable {
    let list: [String]
    let next: String?
}

private struct AddParams: Decodable {
}

private let add = EntityFunc<ListChunk, AddParams>(
    vis: .pri,
    paramsType: AddParams.self,
    f: { (entity, id, lib, params, ctx) in
        .none
    }
)

struct Lists {
    private static let ENTITY_TYPE = "gmrlists"

    private let entityFuncs: EntityFunctions
    private let listEntities: EntitiesPerType

    init(
        appId: String,
        entityFuncs: EntityFunctions,
        libFactory: LibFactory,
        responseSender: ResponseSender,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder,
        db: AppserverDatabase,
        config: Config
    ) throws {
        self.entityFuncs = entityFuncs

        listEntities = try EntitiesPerType(
            appId: appId,
            type: Lists.ENTITY_TYPE,
            entityFactory: NativeEntityFactory(
                entityType: ListChunk.self,
                entityFuncs: [:],
                libFactory: libFactory,
                responseSender: responseSender,
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder
            ),
            db: db,
            config: config
        )
    }

    func add(listId: EntityId, elemToAdd: String) async {
        await entityFuncs.invokePerType(
            params: FunctionParams(
                theFunc: "add",
                ctx: EMPTY_REQUEST_CONTEXT,
                paramsJson: nil
            ),
            id: "",  // TODO
            typeForLogging: Lists.ENTITY_TYPE,
            entitiesPerType: listEntities
        )
    }

    func clear(listId: EntityId) {
    }

    func iterate(
        listId: EntityId,
        iterationFunctionId: String,
        iterationFinishedFunctionId: String,
        customCtx: String?
    ) {
    }

    func remove(listId: EntityId, elemToRemove: String) {
    }
}
