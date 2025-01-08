enum EntityAction {
    case none
    case setEntity
    case deleteEntity
}

struct EntityFuncResult {
    let action: EntityAction
}
