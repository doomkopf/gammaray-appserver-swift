import { AppLib } from "../AppLib";
import { NodeJsFuncResponse } from "./dtos";

export function buildNodeJsFuncResponse(lib: AppLib): NodeJsFuncResponse {
    const dto: NodeJsFuncResponse = {}

    const responseSenderPayload = lib.responseSender.getAndRemoveResponse()
    if (responseSenderPayload) {
        dto.responseSender = responseSenderPayload
    }

    dto.userLogins = lib.user.logins.copyAndClear()
    dto.userLogouts = lib.user.logouts.copyAndClear()
    dto.userSends = lib.user.sends.copyAndClear()
    dto.entityFuncInvokes = lib.entityFunc.invocations.copyAndClear()
    dto.entityQueryInvokes = lib.entityQueries.invocations.copyAndClear()
    dto.httpClientRequest = lib.httpClient.requests.copyAndClear()

    return dto
}
