struct ClientRequestId: Hashable, CustomStringConvertible {
    let value: String

    init(_ value: String) throws {
        if try validate(str: value, minLength: 1, maxLength: 128) {
            self.value = value
        } else {
            throw AppError.General("Invalid client request id: \(value)")
        }
    }

    var description: String {
        value
    }
}
