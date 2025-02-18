export interface NodeJsSetAppRequest {
    id: string,
    code: string,
}

export interface NodeJsSetAppResponse {
    error?: NodeJsSetAppErrorResponse
}

export interface NodeJsSetAppErrorResponse {
    type: NodeJsSetAppErrorResponseType,
    message: string,
}

export enum NodeJsSetAppErrorResponseType {
    SCRIPT_EVALUATION = 0,
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

export enum NodeJsEntityAction {
    NONE = 0,
    SET_ENTITY = 1,
    DELETE_ENTITY = 2,
}

export interface NodeJsEntityFuncRequest {
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
    responseSender?: NodeJsResponseSenderPayload
    userLogins?: NodeJsUserFunctionsLogin[]
    userLogouts?: string[]
    userSends?: NodeJsUserFunctionsSendPayload[]
    entityFuncInvokes?: NodeJsEntityFuncInvokePayload[]
    entityQueryInvokes?: NodeJsEntityQueryInvokePayload[]
    httpClientRequest?: NodeJsHttpClientRequest[]
}

export interface NodeJsEntityFuncResponse {
    general: NodeJsFuncResponse
    action: NodeJsEntityAction
    entityJson?: string
}

export interface NodeJsStatelessFuncRequest {
    appId: string
    requestId: string | null
    requestingUserId: string | null
    persistentLocalClientId: string | null
    sfunc: string
    paramsJson: string | null
}

export interface NodeJsStatelessFuncResponse {
    general: NodeJsFuncResponse
}

export interface NodeJsResponseSenderPayload {
    requestId: string
    objJson: string
}

export interface NodeJsUserFunctionsLogin {
    userId: string
    funcId: string
    customCtxJson?: string
}

export interface NodeJsUserFunctionsSendPayload {
    userId: string
    objJson: string
}

export interface NodeJsEntityFuncInvokePayload {
    type: string
    _func: string
    entityId: string
    paramsJson: string | null
}

export interface NodeJsEntityQueryInvokePayload {
    entityType: string
    queryFinishedFunctionId: string
    query: NodeJsEntityQuery
    customCtxJson?: string
}

export interface NodeJsEntityQuery {
    attributes: NodeJsEntityQueryAttribute[]
}

export interface NodeJsEntityQueryAttribute {
    name: string
    value: NodeJsEntityQueryAttributeValue
}

export interface NodeJsEntityQueryAttributeValue {
    match?: string
    range?: NodeJsEntityQueryAttributeNumberRange
}

export interface NodeJsEntityQueryAttributeNumberRange {
    min?: number
    max?: number
}

export interface NodeJsHttpClientRequest {
    url: string
    method: NodeJsHttpMethod
    body?: string
    headers: NodeJsHttpHeader[]
    resultFunc: string
    requestCtxJson?: string
}

export enum NodeJsHttpMethod {
    GET = "GET",
    POST = "POST",
    PUT = "PUT",
    PATCH = "PATCH",
    DELETE = "DELETE",
}

export interface NodeJsHttpHeader {
    key: string
    value: string
}
