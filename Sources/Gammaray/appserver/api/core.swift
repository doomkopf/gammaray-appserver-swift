struct GammarayApp {
    let sfunc: [String: StatelessFunc]
    let entity: [String: EntityType]
}

typealias EntityId = String

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

struct EntityFunc {
    let vis: FuncVisibility
}

protocol FuncContext: Sendable {
    var requestId: String? { get }
    var persistentLocalClientId: String? { get }
    var requestingUserId: EntityId? { get }
    func sendResponse(objJson: String)
}

enum HttpMethod {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

struct HttpHeader {
    let key: String
    let value: String
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
