struct NodeJsEntityFactory: EntityFactory {
    private let loggerFactory: LoggerFactory
    private let nodeJs: NodeJsAppApi
    private let funcResponseHandler: NodeJsFuncResponseHandler

    init(
        loggerFactory: LoggerFactory,
        nodeJs: NodeJsAppApi,
        funcResponseHandler: NodeJsFuncResponseHandler
    ) {
        self.loggerFactory = loggerFactory
        self.nodeJs = nodeJs
        self.funcResponseHandler = funcResponseHandler
    }

    func create(appId: String, type: String, id: EntityId, databaseEntity: String?) -> Entity {
        return NodeJsEntity(
            loggerFactory: loggerFactory,
            appId: appId,
            entityId: id.value,
            entityType: type,
            nodeJs: nodeJs,
            funcResponseHandler: funcResponseHandler,
            e: databaseEntity
        )
    }
}
