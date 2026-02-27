import Foundation

struct EntityId: Hashable, CustomStringConvertible {
    let value: String

    init(_ value: String) throws {
        if try validate(str: value, minLength: 3, maxLength: 128) {
            self.value = value
        } else {
            throw AppError.General("Invalid entity id: \(value)")
        }
    }

    init() {
        value = UUID().uuidString.lowercased()
    }

    var description: String {
        value
    }
}
