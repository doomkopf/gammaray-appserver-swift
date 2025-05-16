enum HttpMethod {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

typealias HttpHeaders = [String: String]

protocol ApiHttpClient: Sendable {
    func request(
        url: String,
        method: HttpMethod,
        body: String?,
        headers: HttpHeaders,
        resultFunc: String,
        ctxPayload: String?
    )
}
