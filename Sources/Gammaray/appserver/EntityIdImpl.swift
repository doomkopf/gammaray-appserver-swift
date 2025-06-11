struct EntityIdImpl: EntityId {
    let value: String

    init(_ value: String) throws {
        let isMatch = (try Regex("^[A-Za-z0-9-_]*$").wholeMatch(in: value)) != nil
        if value.count >= 3 && value.count <= 128 && isMatch {
            self.value = value
        } else {
            throw AppserverError.General("Invalid entity id")
        }
    }

    init() {
        value = randomUuidString().lowercased()
    }
}
