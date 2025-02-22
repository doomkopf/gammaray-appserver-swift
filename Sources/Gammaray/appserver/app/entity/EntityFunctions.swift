final class EntityFunctions: Sendable {
    private let log: Logger
    private let appId: String
    private let appEntities: AppEntities

    init(
        loggerFactory: LoggerFactory,
        appId: String,
        appEntities: AppEntities
    ) {
        log = loggerFactory.createForClass(EntityFunctions.self)
        self.appId = appId
        self.appEntities = appEntities
    }

    func invoke(params: FunctionParams, entityParams: EntityParams) async {

        // later entity routing here

        guard
            let entitiesPerType = appEntities.getEntitiesByType(entityParams.type)
        else {
            log.log(LogLevel.WARN, "Unknown entity type: \(entityParams.type)", nil)
            return
        }

        let entityContainer = await entitiesPerType.retrieveEntity(entityParams.id)
        do {
            let result = try await entityContainer.invokeFunction(
                theFunc: params.theFunc, paramsJson: params.paramsJson, ctx: params.ctx)
            if result.action == EntityAction.deleteEntity {
                await entitiesPerType.deleteEntity(entityParams.id)
            }
        } catch {
            log.log(
                LogLevel.ERROR,
                "Error executing entity function: appId=\(appId), type=\(entityParams.type), func=\(params.theFunc)",
                error)
        }
    }
}
