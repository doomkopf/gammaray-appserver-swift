protocol AppserverDatabase: Sendable {
    func getAppEntity(appId: String, entityType: String, entityId: EntityId) async -> String?
    func putAppEntity(appId: String, entityType: String, entityId: EntityId, entityStr: String)
        async
    func removeAppEntity(appId: String, entityType: String, entityId: EntityId) async
    func getApp(_ appId: String) async throws -> DatabaseApp?
}

final class AppserverDatabaseImpl: AppserverDatabase {
    private let db: Database
    private let jsonDecoder: StringJSONDecoder

    init(
        db: Database,
        jsonDecoder: StringJSONDecoder
    ) {
        self.db = db
        self.jsonDecoder = jsonDecoder
    }

    private func entityFullKey(appId: String, entityType: String, entityId: EntityId) -> String {
        "\(appId)_\(entityType)_\(entityId)"
    }

    func getAppEntity(appId: String, entityType: String, entityId: EntityId) async -> String? {
        await db.get(entityFullKey(appId: appId, entityType: entityType, entityId: entityId))
    }

    func putAppEntity(appId: String, entityType: String, entityId: EntityId, entityStr: String)
        async
    {
        await db.put(
            entityFullKey(appId: appId, entityType: entityType, entityId: entityId), entityStr)
    }

    func removeAppEntity(appId: String, entityType: String, entityId: EntityId) async {
        await db.remove(entityFullKey(appId: appId, entityType: entityType, entityId: entityId))
    }

    private func appCodeKey(_ appId: String) -> String {
        "\(appId)_code"
    }

    func getApp(_ appId: String) async throws -> DatabaseApp? {
        guard let result = await db.get(appCodeKey(appId)) else {
            return nil
        }

        return try jsonDecoder.decode(DatabaseApp.self, result)
    }
}

enum DatabaseAppType: Int, Encodable, Decodable {
    case NODEJS = 0
}

struct DatabaseApp: Encodable, Decodable {
    let type: DatabaseAppType
    let code: String
}
