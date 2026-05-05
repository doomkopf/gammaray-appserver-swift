protocol Entity: Sendable {
    func invokeFunction(theFunc: FunctionName, payload: String?, ctx: RequestContext) async throws
        -> EntityAction
    func toJSON() async -> JSON?
}

enum EntityAction {
    case none
    case setEntity
    case deleteEntity
}
