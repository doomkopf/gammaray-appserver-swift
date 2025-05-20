private let ENTITY_TYPE = "gamlists"

private struct ListChunk: Codable {
    var list: [String]
    var next: String?
}

private struct AddParams: Codable {
    let e: String
    let maxElems: Int
}

private let addFunc = EntityFunc(
    vis: .pri,
    payloadType: AddParams.self,
    f: { (entity, id, lib, payload, ctx) in
        let entity = entity as! ListChunk?
        let payload = payload as! AddParams?

        guard let payload else {
            return .none
        }

        var listChunk: ListChunk
        if let entity {
            listChunk = entity
        } else {
            listChunk = ListChunk(list: [], next: nil)
        }

        if listChunk.list.count >= payload.maxElems {
            let nextChunkId = randomUuidString()

            let entityFuncPayload = ListChunk(
                list: listChunk.list,
                next: listChunk.next
            )
            lib.entityFunc.invoke(
                entityType: ENTITY_TYPE,
                theFunc: "addNext",
                entityId: nextChunkId,
                payload: entityFuncPayload,
                ctx: EMPTY_REQUEST_CONTEXT
            )

            listChunk.list = []
            listChunk.next = nextChunkId
        }

        listChunk.list.append(payload.e)

        return .setEntity(listChunk)
    }
)

private let addNextFunc = EntityFunc(
    vis: .pri,
    payloadType: ListChunk.self,
    f: { (entity, id, lib, payload, ctx) in
        let listChunk = payload as! ListChunk?

        guard let listChunk else {
            return .none
        }

        return .setEntity(listChunk)
    }
)

struct Lists {
    private let listEntities: EntitiesPerType
    private let jsonEncoder: StringJSONEncoder
    private let maxElemsPerChunk: Int

    init(
        appId: String,
        libFactory: LibFactory,
        responseSender: ResponseSender,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder,
        db: AppserverDatabase,
        config: Config
    ) throws {
        self.jsonEncoder = jsonEncoder

        maxElemsPerChunk = config.getInt(.listEntityMaxElemsPerChunk)

        listEntities = try EntitiesPerType(
            appId: appId,
            type: ENTITY_TYPE,
            entityFactory: NativeEntityFactory(
                entityType: ListChunk.self,
                entityFuncs: [
                    "add": addFunc,
                    "addNext": addNextFunc,
                ],
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
        await listEntities.invoke(
            params: FunctionParams(
                theFunc: "add",
                ctx: EMPTY_REQUEST_CONTEXT,
                payload: jsonEncoder.encode(AddParams(e: elemToAdd, maxElems: maxElemsPerChunk))
            ),
            id: listId
        )
    }

    func clear(listId: EntityId) {
    }

    func iterate(
        listId: EntityId,
        iterationFunctionId: String,
        iterationFinishedFunctionId: String,
        ctxPayload: String?
    ) {
    }

    func remove(listId: EntityId, elemToRemove: String) {
    }

    func scheduledTasks() async {
        await listEntities.scheduledTasks()
    }
}
