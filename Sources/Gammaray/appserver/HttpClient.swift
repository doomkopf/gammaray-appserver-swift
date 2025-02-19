protocol HttpClient: Sendable {
    func request(
        url: String,
        method: HttpMethod,
        body: String?,
        headers: [HttpHeader],
        resultFunc: String,
        requestCtxJson: String?
    ) async
}
