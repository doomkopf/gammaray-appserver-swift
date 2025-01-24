@available(macOS 10.15, *)
final class EntitiesContainers: Sendable {
    private let typeToEntities: [String: EntitiesContainer]

    init(
        appId: String,
        appDef: GammarayApp,
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        config: Config
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
    }

    func cleanEntities() async {
        for entry in typeToEntities {
            await entry.value.cleanEntities()
        }
    }

    func getEntitiesContainerByType(_ type: String) -> EntitiesContainer? {
        typeToEntities[type]
    }
}
