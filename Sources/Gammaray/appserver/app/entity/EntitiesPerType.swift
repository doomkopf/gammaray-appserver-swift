actor EntitiesPerType: CacheListener {
    private let log: Logger
    private let appId: String
    private let type: String
    private let entityFactory: EntityFactory
    private let db: AppserverDatabase
    private let cache: any Cache<EntityContainer>

    init(
        loggerFactory: LoggerFactory,
        appId: String,
        type: String,
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        cache: any Cache<EntityContainer>
    ) {
        log = loggerFactory.createForClass(EntitiesPerType.self)
        self.appId = appId
        self.type = type
        self.entityFactory = entityFactory
        self.db = db
        self.cache = cache
    }

    init(
        loggerFactory: LoggerFactory,
        appId: String,
        type: String,
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        config: Config
    ) throws {
        self.init(
            loggerFactory: loggerFactory,
            appId: appId,
            type: type,
            entityFactory: entityFactory,
            db: db,
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
                entityId: try EntityIdImpl(key),
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
                    entityId: try EntityIdImpl(key),
                    db: self.db
                )
            }
        }
    }

    func invoke(params: FunctionParams, id: EntityId) async {
        do {
            let entityContainer = try await retrieveEntity(id)
            let result = try await entityContainer.invokeFunction(
                theFunc: params.theFunc, payload: params.payload, ctx: params.ctx)
            if result == .deleteEntity {
                await deleteEntity(id)
            }
        } catch {
            log.log(
                .ERROR,
                "Error executing entity function: appId=\(appId), type=\(type), func=\(params.theFunc)",
                error
            )
        }
    }

    private func retrieveEntity(_ key: EntityId) async throws -> EntityContainer {
        guard let entityContainer = cache.get(key: key.value)
        else {
            let databaseEntity = await db.getAppEntity(
                appId: appId, entityType: type, entityId: key)

            if let meanwhileCreatedEntityContainer = cache.get(key: key.value) {
                return meanwhileCreatedEntityContainer
            }

            let entityContainer = EntityContainer(
                entity: try await entityFactory.create(
                    appId: appId,
                    type: type,
                    id: key,
                    databaseEntity: databaseEntity
                ),
                dirty: false
            )

            cache.put(key: key.value, value: entityContainer)

            return entityContainer
        }

        return entityContainer
    }

    func deleteEntity(_ key: EntityId) async {
        _ = cache.remove(key.value)
        await db.removeAppEntity(appId: appId, entityType: type, entityId: key)
    }
}
