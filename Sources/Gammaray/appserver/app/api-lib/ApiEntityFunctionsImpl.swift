struct ApiEntityFunctionsImpl: ApiEntityFunctions {
    let entityFuncs: EntityFunctions

    func invoke(
        entityType: String,
        theFunc: String,
        entityId: EntityId,
        payload: String?,
        ctx: RequestContext
    ) {
        Task {
            await entityFuncs.invoke(
                params: FunctionParams(
                    theFunc: theFunc,
                    ctx: ctx,
                    payload: payload
                ),
                entityParams: EntityParams(type: entityType, id: entityId)
            )
        }
    }
}
