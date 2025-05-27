struct EntityIdImpl: EntityId {
    let value: String

    init(_ value: String) throws {
        // TODO validate
        self.value = value
    }

    init() {
        value = "TODO"
    }
}
