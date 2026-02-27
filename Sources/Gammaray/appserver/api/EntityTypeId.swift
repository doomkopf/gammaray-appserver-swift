struct EntityTypeId: Hashable, CustomStringConvertible {
    let value: String

    init(_ value: String) throws {
        if try validate(str: value, minLength: 3, maxLength: 64) {
            self.value = value
        } else {
            throw AppError.General("Invalid entity type id: \(value)")
        }
    }

    var description: String {
        value
    }
}
