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
    id: string
    type: string
    efunc: string
    entityJson: string | null
    paramsJson: string | null
}

export interface NodeJsFuncResponse {
    responseSenderSend?: NodeJsResponseSenderSend
    userFunctionsLogin?: NodeJsUserFunctionsLogin[]
    userFunctionsLogout?: string[]
    userFunctionsSend?: NodeJsUserFunctionsSend[]
    entityFunctionsInvoke?: NodeJsEntityFunctionsInvoke[]
    entityQueriesQuery?: NodeJsEntityQueriesQuery[]
    httpClientRequest?: NodeJsHttpClientRequest[]
    listsAdd?: NodeJsListsAdd[]
    listsClear?: NodeJsListsClear[]
    listsIterate?: NodeJsListsIterate[]
    listsRemove?: NodeJsListsRemove[]
    loggerLog?: NodeJsLoggerLog[]
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
    sfunc: string
    paramsJson: string | null
}

export interface NodeJsStatelessFuncResponse {
    general: NodeJsFuncResponse
}

export interface NodeJsResponseSenderSend {
    requestId: string
    objJson: string
}

export interface NodeJsUserFunctionsLogin {
    userId: string
    funcId: string
    customCtxJson?: string
}

export interface NodeJsUserFunctionsSend {
    userId: string
    objJson: string
}

export interface NodeJsEntityFunctionsInvoke {
    type: string
    _func: string
    entityId: string
    paramsJson: string | null
}

export interface NodeJsEntityQueriesQuery {
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

export interface NodeJsListsAdd {
    listId: string,
    elemToAdd: string,
}

export interface NodeJsListsClear {
    listId: string,
}

export interface NodeJsListsIterate {
    listId: string
    iterationFunctionId: string
    iterationFinishedFunctionId: string
    customCtxJson?: string
}

export interface NodeJsListsRemove {
    listId: string
    elemToRemove: string
}

export interface NodeJsLoggerLog {
    logLevel: NodeJsLogLevel
    message: string
}

export enum NodeJsLogLevel {
    ERROR = "ERROR",
    WARN = "WARN",
    INFO = "INFO",
    DEBUG = "DEBUG",
}
