@available(macOS 10.15, *)
final class AppEntities: Sendable {
    private let typeToEntities: [String: EntitiesPerType]
    private let cleanEntitiesTask: ScheduledTask

    init(
        appId: String,
        appDef: GammarayApp,
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        config: Config,
        scheduler: Scheduler
    ) throws {
        var typeToEntities: [String: EntitiesPerType] = [:]
        for key in appDef.entity.keys {
            typeToEntities[key] = try EntitiesPerType(
                appId: appId,
                type: key,
                entityFactory: entityFactory,
                db: db,
                config: config
            )
        }
        self.typeToEntities = typeToEntities

        cleanEntitiesTask = scheduler.scheduleInterval(
            millis: config.getInt64(ConfigProperty.entityScheduledTasksIntervalMillis))
        cleanEntitiesTask.setFuncNotAwaiting {
            await self.scheduledTasks()
        }
    }

    private func scheduledTasks() async {
        for value in typeToEntities.values {
            await value.scheduledTasks()
        }
    }

    func getEntitiesByType(_ type: String) -> EntitiesPerType? {
        typeToEntities[type]
    }

    func shutdown() async {
        await cleanEntitiesTask.cancel()
    }
}
