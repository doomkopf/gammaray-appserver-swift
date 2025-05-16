protocol ApiEntityQueries: Sendable {
    func query(
        entityType: String,
        queryFinishedFunctionId: String,
        query: EntityQuery,
        ctxPayload: String?
    )
}
