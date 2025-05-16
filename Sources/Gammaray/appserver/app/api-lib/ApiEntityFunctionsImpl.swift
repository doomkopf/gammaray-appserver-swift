struct ApiEntityFunctionsImpl: ApiEntityFunctions {
    let entityFuncs: EntityFunctions
    let jsonEncoder: StringJSONEncoder

    func invoke(
        entityType: String,
        theFunc: String,
        entityId: EntityId,
        payload: FuncPayload?,
        ctx: RequestContext
    ) {
        var stringPayload: String?
        if let payload {
            stringPayload = jsonEncoder.encode(payload)
        }
        Task {
            await entityFuncs.invoke(
                params: FunctionParams(
                    theFunc: theFunc,
                    ctx: ctx,
                    payload: stringPayload
                ),
                entityParams: EntityParams(type: entityType, id: entityId)
            )
        }
    }
}
