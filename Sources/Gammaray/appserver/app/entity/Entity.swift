protocol Entity: Sendable {
    func invokeFunction(theFunc: String, payload: String?, ctx: RequestContext) async throws
        -> EntityAction
    func toString() async -> String?
}

enum EntityAction {
    case none
    case setEntity
    case deleteEntity
}
