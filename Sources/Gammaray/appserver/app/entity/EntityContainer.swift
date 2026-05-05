actor EntityContainer {
    private let log: Logger
    private let entity: Entity
    private var dirty: Bool

    init(
        loggerFactory: LoggerFactory,
        entity: Entity,
        dirty: Bool
    ) {
        log = loggerFactory.createForClass(EntityContainer.self)
        self.entity = entity
        self.dirty = dirty
    }

    func invokeFunction(theFunc: FunctionName, payload: String?, ctx: RequestContext) async throws
        -> EntityAction
    {
        let result = try await entity.invokeFunction(
            theFunc: theFunc, payload: payload, ctx: ctx)

        if result == .setEntity {
            dirty = true
        }

        return result
    }

    func store(appId: AppId, entityType: EntityTypeId, entityId: EntityId, db: AppserverDatabase)
        async
    {
        if !dirty {
            return
        }

        dirty = false

        if let entity = await entity.toJSON() {
            do {
                try await db.putAppEntity(
                    appId: appId, entityType: entityType, entityId: entityId, entity: entity)
            } catch {
                log.log(
                    .ERROR,
                    "Error storing entity: appId=\(appId), entityType=\(entityType), entityId=\(entityId)",
                    error)
            }
        }
    }
}
