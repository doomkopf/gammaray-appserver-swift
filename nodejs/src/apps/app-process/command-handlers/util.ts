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
    dto.httpClientRequests = lib.httpClient.requests.copyAndClear()
    dto.listAdds = lib.listFunc.adds.copyAndClear()
    dto.listClears = lib.listFunc.clears.copyAndClear()
    dto.listIterates = lib.listFunc.iterates.copyAndClear()
    dto.listRemoves = lib.listFunc.removes.copyAndClear()
    dto.logs = lib.log.logs.copyAndClear()

    return dto
}
