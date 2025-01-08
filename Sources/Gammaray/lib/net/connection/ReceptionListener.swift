protocol ReceptionListener: Sendable {
    func onReceived(source: ReceptionSource, frame: String)
}
