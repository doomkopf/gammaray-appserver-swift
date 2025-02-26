struct AppEntities {
    private let typeToEntities: [String: EntitiesPerType]

    init(
        appId: String,
        appDef: GammarayApp,
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        config: Config
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
