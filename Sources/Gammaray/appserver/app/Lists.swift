private let ENTITY_TYPE = "gmrlists"
private let LIST_FUNCTIONS_MAX_ELEMENTS_PER_CHUNK = 500000

private struct ListChunk: Codable {
    var list: [String]
    var next: String?
}

private struct AddParams: Decodable {
    let e: String
}

private let addFunc = EntityFunc(
    vis: .pri,
    paramsType: AddParams.self,
    f: { (entity, id, lib, params, ctx) in
        let entity = entity as! ListChunk?
        let params = params as! AddParams?

        guard let params else {
            return .none
        }

        var listChunk: ListChunk
        if let entity {
            listChunk = entity
        } else {
            listChunk = ListChunk(list: [], next: nil)
        }

        if listChunk.list.count >= LIST_FUNCTIONS_MAX_ELEMENTS_PER_CHUNK {
            let nextChunkId = randomUuidString()

            let params = ListChunk(
                list: listChunk.list,
                next: listChunk.next
            )
            lib.entityFunc.invoke(
                entityType: ENTITY_TYPE,
                theFunc: "addNext",
                entityId: nextChunkId,
                params: "TODO params",
                ctx: EMPTY_REQUEST_CONTEXT
            )

            listChunk.list = []
            listChunk.next = nextChunkId
        }

        listChunk.list.append(params.e)

        return .setEntity(listChunk)
    }
)

struct Lists {
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
            type: ENTITY_TYPE,
            entityFactory: NativeEntityFactory(
                entityType: ListChunk.self,
                entityFuncs: ["add": addFunc],
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
            typeForLogging: ENTITY_TYPE,
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
