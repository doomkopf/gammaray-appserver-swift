struct LoginResult: Encodable, Decodable {
    let sessionId: String
    let ctxJson: String?
}
