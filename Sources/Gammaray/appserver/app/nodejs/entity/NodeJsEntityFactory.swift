struct NodeJsEntityFactory: EntityFactory {
    private let nodeJs: NodeJsAppApi
    private let funcResponseHandler: NodeJsFuncResponseHandler

    init(
        nodeJs: NodeJsAppApi,
        funcResponseHandler: NodeJsFuncResponseHandler
    ) {
        self.nodeJs = nodeJs
        self.funcResponseHandler = funcResponseHandler
    }

    func create(appId: String, type: String, id: EntityId, databaseEntity: String?) -> Entity {
        return NodeJsEntity(
            appId: appId,
            entityId: id,
            entityType: type,
            nodeJs: nodeJs,
            funcResponseHandler: funcResponseHandler,
            e: databaseEntity
        )
    }
}
