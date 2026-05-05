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

    func create(appId: AppId, typeId: EntityTypeId, id: EntityId, databaseEntity: JSON?)
        -> Entity
    {
        return NodeJsEntity(
            loggerFactory: loggerFactory,
            appId: appId,
            entityId: id.value,
            entityType: typeId.value,
            nodeJs: nodeJs,
            funcResponseHandler: funcResponseHandler,
            e: databaseEntity
        )
    }
}
