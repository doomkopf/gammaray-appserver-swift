actor EntitiesPerType: CacheListener {
    private let loggerFactory: LoggerFactory
    private let log: Logger
    private let appId: AppId
    private let type: EntityTypeId
    private let entityFactory: EntityFactory
    private let db: AppserverDatabase
    private let cache: any Cache<EntityId, EntityContainer>

    init(
        loggerFactory: LoggerFactory,
        appId: AppId,
        type: EntityTypeId,
        entityFactory: EntityFactory,
        db: AppserverDatabase,
        cache: any Cache<EntityId, EntityContainer>
    ) {
        self.loggerFactory = loggerFactory
        log = loggerFactory.createForClass(EntitiesPerType.self)
        self.appId = appId
        self.type = type
        self.entityFactory = entityFactory
        self.db = db
        self.cache = cache
    }

    init(
        loggerFactory: LoggerFactory,
        appId: AppId,
        type: EntityTypeId,
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
                entityId: try EntityId(key),
                db: db
            )
        }
    }

    func scheduledTasks() async {
        cache.cleanup()
        await storeEntities()
    }

    private func storeEntities() async {
        var entries: [(key: EntityId, value: EntityContainer)] = []
        cache.forEachEntry { key, value in
            entries.append((key: key, value: value))
        }

        for entry in entries {
            await entry.value.store(
                appId: self.appId,
                entityType: self.type,
                entityId: entry.key,
                db: self.db,
            )
        }
    }

    func invoke(params: FunctionParams, id: EntityId) async {
        do {
            let entityContainer = try await retrieveEntity(id)
            let result = try await entityContainer.invokeFunction(
                theFunc: params.theFunc, payload: params.payload, ctx: params.ctx)
            if result == .deleteEntity {
                try await deleteEntity(id)
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
        guard let entityContainer = cache.get(key: key)
        else {
            let databaseEntity = try await db.getAppEntity(
                appId: appId, entityType: type, entityId: key)

            if let meanwhileCreatedEntityContainer = cache.get(key: key) {
                return meanwhileCreatedEntityContainer
            }

            let entityContainer = EntityContainer(
                loggerFactory: loggerFactory,
                entity: try await entityFactory.create(
                    appId: appId,
                    typeId: type,
                    id: key,
                    databaseEntity: databaseEntity
                ),
                dirty: false
            )

            cache.put(key: key, value: entityContainer)

            return entityContainer
        }

        return entityContainer
    }

    private func deleteEntity(_ key: EntityId) async throws {
        _ = cache.remove(key)
        try await db.removeAppEntity(appId: appId, entityType: type, entityId: key)
    }

    func shutdown() async {
        await storeEntities()
    }
}
