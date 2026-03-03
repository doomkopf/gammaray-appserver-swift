struct AppId: Hashable, CustomStringConvertible {
    let value: String

    init(_ value: String) throws {
        if try validate(str: value, minLength: 3, maxLength: 128) {
            self.value = value
        } else {
            throw AppError.General("Invalid app id: \(value)")
        }
    }

    var description: String {
        value
    }
}
