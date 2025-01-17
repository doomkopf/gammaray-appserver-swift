@available(macOS 10.15, *)
actor EntitiesContainer: CacheListener {
    typealias V = EntityContainer

    private let appId: String
    private let type: String
    private let entityFactory: EntityFactory
    private let db: AppserverDatabase
    private let cache: Cache<EntityContainer>

    init(
        appId: String,
        type: String,
        entityFactory: EntityFactory,
        db: AppserverDatabase
    ) throws {
        self.appId = appId
        self.type = type
        self.entityFactory = entityFactory
        self.db = db

        cache = try Cache(
            entryEvictionTimeMillis: 600000,
            maxEntries: 100000
        )
    }

    nonisolated func onEntryEvicted(key: String, value: EntityContainer) {
        Task {
            await value.store(
                appId: appId,
                entityType: type,
                entityId: key,
                db: db
            )
        }
    }

    func cleanEntities() {
        cache.cleanup()
    }

    func retrieveEntity(_ key: EntityId) async -> EntityContainer {
        guard let entityContainer = cache.get(key: key)
        else {
            let databaseEntity = await db.getAppEntity(
                appId: appId, entityType: type, entityId: key)

            if let meanwhileCreatedEntityContainer = cache.get(key: key) {
                return meanwhileCreatedEntityContainer
            }

            let entityContainer = EntityContainer(
                entity: entityFactory.create(
                    appId: appId, type: type, id: key, databaseEntity: databaseEntity), dirty: false
            )

            cache.put(key: key, value: entityContainer)

            return entityContainer
        }

        return entityContainer
    }

    func deleteEntity(_ key: EntityId) async {
        _ = cache.remove(key)
        await db.removeAppEntity(appId: appId, entityType: type, entityId: key)
    }
}
