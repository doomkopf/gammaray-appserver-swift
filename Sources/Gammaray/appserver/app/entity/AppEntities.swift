final class AppEntities: Sendable {
    private let log: Logger
    private let typeToEntities: [String: EntitiesPerType]

    init(
        loggerFactory: LoggerFactory,
        appId: String,
        entityTypes: [String],
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        config: Config
    ) throws {
        log = loggerFactory.createForClass(AppEntities.self)
        var typeToEntities: [String: EntitiesPerType] = [:]
        for type in entityTypes {
            typeToEntities[type] = try EntitiesPerType(
                loggerFactory: loggerFactory,
                appId: appId,
                type: type,
                entityFactory: entityFactory,
                db: db,
                config: config
            )
        }
        self.typeToEntities = typeToEntities
    }

    func scheduledTasks() async {
        for value in typeToEntities.values {
            await value.scheduledTasks()
        }
    }

    func invoke(params: FunctionParams, entityParams: EntityParams) async {
        guard
            let entitiesPerType = typeToEntities[entityParams.type]
        else {
            log.log(.WARN, "Unknown entity type: \(entityParams.type)", nil)
            return
        }

        await entitiesPerType.invoke(
            params: params,
            id: entityParams.id
        )
    }
}
