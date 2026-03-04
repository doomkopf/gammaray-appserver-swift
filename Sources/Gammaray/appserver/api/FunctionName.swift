struct FunctionName: Hashable, CustomStringConvertible {
    let value: String

    init(_ value: String) throws {
        if try validate(str: value, minLength: 1, maxLength: 64) {
            self.value = value
        } else {
            throw AppError.General("Invalid function name: \(value)")
        }
    }

    var description: String {
        value
    }
}
