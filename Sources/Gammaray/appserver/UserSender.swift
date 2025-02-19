protocol UserSender: Sendable {
    func send(userId: EntityId, objJson: String) async
}
