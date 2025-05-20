struct ApiEntityFunctionsImpl: ApiEntityFunctions {
    let appEntities: AppEntities
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
            await appEntities.invoke(
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
