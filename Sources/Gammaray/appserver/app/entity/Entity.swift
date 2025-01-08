protocol Entity: Sendable {
    func invokeFunction(theFunc: String, paramsJson: String?, ctx: RequestContext) async throws
        -> EntityFuncResult
    func toString() async -> String?
}
