struct App {
    private let statelessFunctions: StatelessFunctions
    private let entityFunctions: EntityFunctions
    private let appEntities: AppEntities
    private let lists: Lists

    init(
        statelessFunctions: StatelessFunctions,
        entityFunctions: EntityFunctions,
        appEntities: AppEntities,
        lists: Lists
    ) {
        self.statelessFunctions = statelessFunctions
        self.entityFunctions = entityFunctions
        self.appEntities = appEntities
        self.lists = lists
    }

    func handleFunc(params: FunctionParams, entityParams: EntityParams?) async {
        if let entityParams {
            await entityFunctions.invoke(params: params, entityParams: entityParams)
            return
        }

        await statelessFunctions.invoke(params)
    }

    func scheduledTasks() async {
        await appEntities.scheduledTasks()
        await lists.scheduledTasks()
    }
}
