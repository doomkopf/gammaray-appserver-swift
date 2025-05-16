struct GammarayApp {
    let sfunc: [String: StatelessFunc]
    let entity: [String: EntityType]
}

typealias EntityId = String
typealias RequestId = String
typealias SessionId = String
typealias GammarayEntity = Encodable

enum FuncVisibility {
    case pri
    case pub
}

struct StatelessFunc {
    let vis: FuncVisibility
}

struct EntityType {
    let efunc: [String: EntityFunc]
}

enum EntityFuncResult {
    case none
    case setEntity(GammarayEntity)
    case deleteEntity
}

struct EntityFunc {
    let vis: FuncVisibility
    let paramsType: Decodable.Type
    let f:
        @Sendable
        (
            _ entity: GammarayEntity?,
            _ id: EntityId,
            _ lib: Lib,
            _ params: Any?,
            _ ctx: FuncContext
        ) -> EntityFuncResult
}

protocol FuncContext: Sendable {
    var requestId: RequestId? { get }
    var requestingUserId: EntityId? { get }
    func sendResponse(objJson: String)
}

struct EntityQuery {
    let attributes: [EntityQueryAttribute]
}

struct EntityQueryAttribute {
    let name: String
    let value: EntityQueryAttributeValue
}

struct EntityQueryAttributeValue {
    let match: String?
    let range: EntityQueryAttributeNumberRange?
}

struct EntityQueryAttributeNumberRange {
    let min: Int64?
    let max: Int64?
}

protocol ApiEntityFunctions: Sendable {
    func invoke(
        entityType: String,
        theFunc: String,
        entityId: EntityId,
        params: String?,
        ctx: RequestContext
    )
}

protocol ApiResponseSender: Sendable {
    func send(requestId: RequestId, obj: String)
}
