protocol AppserverDatabase: Sendable {
    func getAppEntity(appId: AppId, entityType: EntityTypeId, entityId: EntityId) async throws
        -> String?
    func putAppEntity(
        appId: AppId, entityType: EntityTypeId, entityId: EntityId, entityStr: String) async throws
    func removeAppEntity(appId: AppId, entityType: EntityTypeId, entityId: EntityId) async throws
    func getApp(_ appId: AppId) async throws -> DatabaseApp?
    func putApp(appId: AppId, app: DatabaseApp) async throws
}

struct AppserverDatabaseImpl: AppserverDatabase {
    private let db: Database
    private let jsonEncoder: StringJSONEncoder
    private let jsonDecoder: StringJSONDecoder

    init(
        db: Database,
        jsonEncoder: StringJSONEncoder,
        jsonDecoder: StringJSONDecoder
    ) {
        self.db = db
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    private func entityFullKey(appId: AppId, entityType: EntityTypeId, entityId: EntityId)
        -> String
    {
        "\(appId)_\(entityType)_\(entityId.value)"
    }

    func getAppEntity(appId: AppId, entityType: EntityTypeId, entityId: EntityId) async throws
        -> String?
    {
        try await db.get(entityFullKey(appId: appId, entityType: entityType, entityId: entityId))
    }

    func putAppEntity(
        appId: AppId, entityType: EntityTypeId, entityId: EntityId, entityStr: String
    )
        async throws
    {
        try await db.put(
            entityFullKey(appId: appId, entityType: entityType, entityId: entityId), entityStr)
    }

    func removeAppEntity(appId: AppId, entityType: EntityTypeId, entityId: EntityId) async throws {
        try await db.remove(entityFullKey(appId: appId, entityType: entityType, entityId: entityId))
    }

    private func appCodeKey(_ appId: AppId) -> String {
        "\(appId)_code"
    }

    func getApp(_ appId: AppId) async throws -> DatabaseApp? {
        guard let result = try await db.get(appCodeKey(appId)) else {
            return nil
        }

        return try jsonDecoder.decode(DatabaseApp.self, result)
    }

    func putApp(appId: AppId, app: DatabaseApp) async throws {
        try await db.put(appCodeKey(appId), jsonEncoder.encode(app))
    }
}

enum DatabaseAppType: Int, Encodable, Decodable {
    case NODEJS = 0
}

struct DatabaseApp: Encodable, Decodable {
    let type: DatabaseAppType
    let code: String
}
