actor EntityContainer {
    private let entity: Entity
    private var dirty: Bool

    init(
        entity: Entity,
        dirty: Bool
    ) {
        self.entity = entity
        self.dirty = dirty
    }

    func invokeFunction(theFunc: String, paramsJson: String?, ctx: RequestContext) async throws
        -> EntityAction
    {
        let result = try await entity.invokeFunction(
            theFunc: theFunc, paramsJson: paramsJson, ctx: ctx)

        if result == .setEntity {
            dirty = true
        }

        return result
    }

    func store(appId: String, entityType: String, entityId: EntityId, db: AppserverDatabase) async {
        if !dirty {
            return
        }

        dirty = false

        if let entityStr = await entity.toString() {
            await db.putAppEntity(
                appId: appId, entityType: entityType, entityId: entityId, entityStr: entityStr)
        }
    }
}
