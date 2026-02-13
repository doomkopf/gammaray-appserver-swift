actor LibContainer {
    private var lib: Lib?

    func lateBind(lib: Lib) {
        self.lib = lib
    }

    func get() throws -> Lib {
        guard let lib else {
            throw AppserverError.General("LibFactory not initialized")
        }

        return lib
    }
}
