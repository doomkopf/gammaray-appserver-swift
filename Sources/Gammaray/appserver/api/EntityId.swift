import Foundation

struct EntityId: Hashable {
    let value: String

    init(_ value: String) throws {
        let isMatch = (try Regex("^[A-Za-z0-9-_]*$").wholeMatch(in: value)) != nil
        if value.count >= 3 && value.count <= 128 && isMatch {
            self.value = value
        } else {
            throw AppError.General("Invalid entity id: \(value)")
        }
    }

    init() {
        value = UUID().uuidString.lowercased()
    }
}
