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
