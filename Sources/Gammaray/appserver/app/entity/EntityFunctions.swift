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
        guard
            let entitiesPerType = appEntities.getEntitiesByType(entityParams.type)
        else {
            log.log(LogLevel.WARN, "Unknown entity type: \(entityParams.type)", nil)
            return
        }

        await invokePerType(
            params: params,
            id: entityParams.id,
            typeForLogging: entityParams.type,
            entitiesPerType: entitiesPerType
        )
    }

    func invokePerType(
        params: FunctionParams,
        id: EntityId,
        typeForLogging: String,
        entitiesPerType: EntitiesPerType
    ) async {
        do {
            let entityContainer = try await entitiesPerType.retrieveEntity(id)
            let result = try await entityContainer.invokeFunction(
                theFunc: params.theFunc, paramsJson: params.paramsJson, ctx: params.ctx)
            if result == .deleteEntity {
                await entitiesPerType.deleteEntity(id)
            }
        } catch {
            log.log(
                LogLevel.ERROR,
                "Error executing entity function: appId=\(appId), type=\(typeForLogging), func=\(params.theFunc)",
                error)
        }
    }
}
