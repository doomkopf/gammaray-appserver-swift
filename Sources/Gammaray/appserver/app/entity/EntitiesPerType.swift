@available(macOS 10.15, *)
actor EntitiesPerType: CacheListener {
    typealias V = EntityContainer

    private let appId: String
    private let type: String
    private let entityFactory: EntityFactory
    private let db: AppserverDatabase
    private let cache: any Cache<EntityContainer>

    init(
        appId: String,
        type: String,
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        cache: any Cache<EntityContainer>
    ) {
        self.appId = appId
        self.type = type
        self.entityFactory = entityFactory
        self.db = db
        self.cache = cache
    }

    init(
        appId: String,
        type: String,
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        config: Config
    ) throws {
        self.init(
            appId: appId, type: type, entityFactory: entityFactory, db: db,
            cache: try CacheImpl(
                entryEvictionTimeMillis: config.getInt64(
                    ConfigProperty.entityCacheEvictionTimeMillis),
                maxEntries: config.getInt(ConfigProperty.entityCacheMaxEntries)
            )
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

    func scheduledTasks() {
        cache.cleanup()
        storeEntities()
    }

    private func storeEntities() {
        cache.forEachEntry { key, value in
            Task {
                await value.store(
                    appId: self.appId,
                    entityType: self.type,
                    entityId: key,
                    db: self.db
                )
            }
        }
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
