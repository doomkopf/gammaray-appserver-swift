struct AppDescription {
    let statelessFuncs: [FunctionName: StatelessFuncDescription]
    let entityTypes: [EntityTypeId: EntityTypeDescription]

    func isFunctionPublic(params: FunctionParams, entityParams: EntityParams?) -> Bool {
        if let entityParams {
            return entityTypes[entityParams.typeId]?.funcs[params.theFunc]?.visibility == .pub
        }
        return statelessFuncs[params.theFunc]?.visibility == .pub
    }
}

struct StatelessFuncDescription {
    let visibility: FuncVisibility
}

struct EntityTypeDescription {
    let funcs: [FunctionName: EntityFuncDescription]
}

struct EntityFuncDescription {
    let visibility: FuncVisibility
}
