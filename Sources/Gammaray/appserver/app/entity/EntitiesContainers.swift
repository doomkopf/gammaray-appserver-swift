@available(macOS 10.15, *)
final class EntitiesContainers: Sendable {
    private let typeToEntities: [String: EntitiesContainer]
    private let cleanEntitiesTask: ScheduledTask

    init(
        appId: String,
        appDef: GammarayApp,
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        config: Config,
        scheduler: Scheduler
    ) throws {
        var typeToEntities: [String: EntitiesContainer] = [:]
        for entry in appDef.entity {
            typeToEntities[entry.key] = try EntitiesContainer(
                appId: appId,
                type: entry.key,
                entityFactory: entityFactory,
                db: db,
                config: config
            )
        }
        self.typeToEntities = typeToEntities

        cleanEntitiesTask = scheduler.scheduleInterval(
            millis: config.getInt64(ConfigProperty.entityCacheCleanupIntervalMillis))
        cleanEntitiesTask.setFuncNotAwaiting {
            await self.cleanEntities()
        }
    }

    private func cleanEntities() async {
        for entry in typeToEntities {
            await entry.value.cleanEntities()
        }
    }

    func getEntitiesContainerByType(_ type: String) -> EntitiesContainer? {
        typeToEntities[type]
    }

    func shutdown() async {
        await cleanEntitiesTask.cancel()
    }
}
