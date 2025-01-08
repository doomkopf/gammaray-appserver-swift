export interface NodeJsSetAppRequest {
    id: string,
    code: string,
}

export interface NodeJsSetAppResponse {
}

export interface NodeJsGetAppDefinitionRequest {
    appId: string,
}

export interface NodeJsGammarayApp {
    sfunc: { [func: string]: NodeJsStatelessFunc },
    entity: { [type: string]: NodeJsEntityType },
}

export interface NodeJsStatelessFunc {
    vis: NodeJsFuncVisibility,
}

export interface NodeJsEntityType {
    efunc: { [func: string]: NodeJsEntityFunc },
}

export interface NodeJsEntityFunc {
    vis: NodeJsFuncVisibility,
}

export enum NodeJsFuncVisibility {
    PRI = 1,
    PUB = 2,
}

export enum EntityAction {
    NONE = 0,
    SET_ENTITY = 1,
    DELETE_ENTITY = 2,
}

export interface EntityFuncRequest {
    appId: string
    requestId: string | null
    requestingUserId: string | null
    persistentLocalClientId: string | null
    id: string
    type: string
    efunc: string
    entityJson: string | null
    paramsJson: string | null
}

export interface NodeJsFuncResponse {
    responseSender?: ResponseSenderPayload
    entityFuncInvokes?: EntityFuncInvokePayload[]
}

export interface EntityFuncResponse {
    general: NodeJsFuncResponse
    action: EntityAction
    entityJson?: string
}

export interface StatelessFuncRequest {
    appId: string
    requestId: string | null
    requestingUserId: string | null
    persistentLocalClientId: string | null
    sfunc: string
    paramsJson: string | null
}

export interface StatelessFuncResponse {
    general: NodeJsFuncResponse
}

export interface ResponseSenderPayload {
    requestId: string
    objJson: string
}

export interface EntityFuncInvokePayload {
    type: string
    _func: string
    entityId: string
    paramsJson: string | null
}
