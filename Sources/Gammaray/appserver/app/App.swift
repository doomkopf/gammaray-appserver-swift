@available(macOS 10.15, *)
class App {
    private let statelessFunctions: StatelessFunctions
    private let entityFunctions: EntityFunctions

    init(
        statelessFunctions: StatelessFunctions,
        entityFunctions: EntityFunctions
    ) {
        self.statelessFunctions = statelessFunctions
        self.entityFunctions = entityFunctions
    }

    func handleFunc(params: FunctionParams, entityParams: EntityParams?) async {
        if let entity = entityParams {
            await entityFunctions.invoke(params: params, entityParams: entity)
            return
        }

        await statelessFunctions.invoke(params)
    }
}
