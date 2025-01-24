@available(macOS 10.15, *)
class App {
    private let statelessFunctions: StatelessFunctions
    private let entityFunctions: EntityFunctions
    private let entitiesContainers: EntitiesContainers

    init(
        statelessFunctions: StatelessFunctions,
        entityFunctions: EntityFunctions,
        entitiesContainers: EntitiesContainers
    ) {
        self.statelessFunctions = statelessFunctions
        self.entityFunctions = entityFunctions
        self.entitiesContainers = entitiesContainers
    }

    func handleFunc(params: FunctionParams, entityParams: EntityParams?) async {
        if let entity = entityParams {
            await entityFunctions.invoke(params: params, entityParams: entity)
            return
        }

        await statelessFunctions.invoke(params)
    }

    func shutdown() async {
        await entitiesContainers.shutdown()
    }
}
