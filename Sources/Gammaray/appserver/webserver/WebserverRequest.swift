protocol WebserverRequest: Sendable {
    func respond(body: String, status: HttpStatus, headers: [HttpHeader]?) async
}
