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

    func getEntitiesByType(_ type: String) -> EntitiesPerType? {
        typeToEntities[type]
    }
}
