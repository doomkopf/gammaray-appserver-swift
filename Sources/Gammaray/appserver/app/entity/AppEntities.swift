struct AppEntities {
    private let typeToEntities: [String: EntitiesPerType]

    init(
        appId: String,
        entityTypes: [String],
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        config: Config
    ) throws {
        var typeToEntities: [String: EntitiesPerType] = [:]
        for type in entityTypes {
            typeToEntities[type] = try EntitiesPerType(
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
            // TODO
            //log.log(LogLevel.WARN, "Unknown entity type: \(entityParams.type)", nil)
            return
        }

        await entitiesPerType.invoke(
            params: params,
            id: entityParams.id
        )
    }
}
