@available(macOS 10.15, *)
class App {
    private let statelessFunctions: StatelessFunctions
    private let entityFunctions: EntityFunctions
    private let appEntities: AppEntities

    init(
        statelessFunctions: StatelessFunctions,
        entityFunctions: EntityFunctions,
        appEntities: AppEntities
    ) {
        self.statelessFunctions = statelessFunctions
        self.entityFunctions = entityFunctions
        self.appEntities = appEntities
    }

    func handleFunc(params: FunctionParams, entityParams: EntityParams?) async {
        if let entity = entityParams {
            await entityFunctions.invoke(params: params, entityParams: entity)
            return
        }

        await statelessFunctions.invoke(params)
    }

    func shutdown() async {
        await appEntities.shutdown()
    }
}
