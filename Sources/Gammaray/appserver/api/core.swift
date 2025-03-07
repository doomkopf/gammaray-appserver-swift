struct GammarayApp {
    let sfunc: [String: StatelessFunc]
    let entity: [String: EntityType]
}

typealias EntityId = String
typealias RequestId = String
typealias SessionId = String

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
