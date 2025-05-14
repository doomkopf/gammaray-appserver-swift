struct ApiEntityFunctionsImpl: ApiEntityFunctions {
    let entityFuncs: EntityFunctions

    func invoke(
        entityType: String,
        theFunc: String,
        entityId: EntityId,
        params: String?,
        ctx: RequestContext
    ) {
        Task {
            await entityFuncs.invoke(
                params: FunctionParams(
                    theFunc: theFunc,
                    ctx: ctx,
                    paramsJson: params
                ),
                entityParams: EntityParams(type: entityType, id: entityId)
            )
        }
    }
}
