actor ApiEntityFunctionsImpl: ApiEntityFunctions {
    private var entityFuncs: EntityFunctions?

    func lateBind(entityFuncs: EntityFunctions) {
        self.entityFuncs = entityFuncs
    }

    nonisolated func invoke(
        entityType: String,
        theFunc: String,
        entityId: EntityId,
        params: String?
    ) {
        let ctx = RequestContextContainer.$ctx.get()

        Task {
            await invoke(
                entityType: entityType,
                theFunc: theFunc,
                entityId: entityId,
                paramsJson: params,
                ctx: ctx
            )
        }
    }

    func invoke(
        entityType: String,
        theFunc: String,
        entityId: EntityId,
        paramsJson: String?,
        ctx: RequestContext
    ) async {
        guard let entityFuncs else {
            return
        }

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
