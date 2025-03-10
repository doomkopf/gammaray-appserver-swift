struct ApiEntityFunctionsImpl: ApiEntityFunctions {
    let entityFuncs: EntityFunctions
    let jsonEncoder: StringJSONEncoder

    func invoke(entityType: String, theFunc: String, entityId: EntityId, params: Encodable?) {
        let ctx = RequestContextContainer.$ctx.get()

        let paramsJson: String?
        if let params {
            paramsJson = jsonEncoder.encode(params)
        } else {
            paramsJson = nil
        }

        Task {
            await entityFuncs.invoke(
                params: FunctionParams(
                    theFunc: theFunc,
                    ctx: ctx,
                    paramsJson: paramsJson
                ),
                entityParams: EntityParams(type: entityType, id: entityId)
            )
        }
    }
}
