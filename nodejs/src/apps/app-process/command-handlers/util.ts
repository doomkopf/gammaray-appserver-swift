import { AppLib } from "../AppLib";
import { NodeJsFuncResponse } from "./dtos";

export function buildNodeJsFuncResponse(lib: AppLib): NodeJsFuncResponse {
    const dto: NodeJsFuncResponse = {}

    const responseSenderSend = lib.responseSender.getAndRemoveResponse()
    if (responseSenderSend) {
        dto.responseSenderSend = responseSenderSend
    }

    dto.userFunctionsLogin = lib.user.logins.copyAndClear()
    dto.userFunctionsLogout = lib.user.logouts.copyAndClear()
    dto.userFunctionsSend = lib.user.sends.copyAndClear()
    dto.entityFunctionsInvoke = lib.entityFunc.invocations.copyAndClear()
    dto.httpClientRequest = lib.httpClient.requests.copyAndClear()
    dto.loggerLog = lib.log.logs.copyAndClear()

    return dto
}
