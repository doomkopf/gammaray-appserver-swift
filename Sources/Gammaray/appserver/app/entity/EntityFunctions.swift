@available(macOS 10.15, *)
final class EntityFunctions: Sendable {
    private let log: Logger
    private let appId: String
    private let entitiesContainers: EntitiesContainers
    private let cleanEntitiesTask: ScheduledTask

    init(
        loggerFactory: LoggerFactory,
        appId: String,
        entitiesContainers: EntitiesContainers,
        scheduler: Scheduler,
        config: Config
    ) {
        log = loggerFactory.createForClass(EntityFunctions.self)
        self.appId = appId
        self.entitiesContainers = entitiesContainers

        cleanEntitiesTask = scheduler.scheduleInterval(
            millis: config.getInt64(ConfigProperty.entityCacheCleanupIntervalMillis))
        cleanEntitiesTask.setFuncNotAwaiting {
            await entitiesContainers.cleanEntities()
        }
    }

    func invoke(params: FunctionParams, entityParams: EntityParams) async {

        // later entity routing here

        guard
            let entitiesContainer = entitiesContainers.getEntitiesContainerByType(entityParams.type)
        else {
            log.log(LogLevel.WARN, "Unknown entity type: \(entityParams.type)", nil)
            return
        }

        let entityContainer = await entitiesContainer.retrieveEntity(entityParams.id)
        do {
            let result = try await entityContainer.invokeFunction(
                theFunc: params.theFunc, paramsJson: params.paramsJson, ctx: params.ctx)
            if result.action == EntityAction.deleteEntity {
                await entitiesContainer.deleteEntity(entityParams.id)
            }
        } catch {
            log.log(
                LogLevel.ERROR,
                "Error executing entity function: appId=\(appId), type=\(entityParams.type), func=\(params.theFunc)",
                error)
        }
    }

    func shutdown() async {
        await cleanEntitiesTask.cancel()
    }
}
