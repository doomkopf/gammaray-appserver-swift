import { RequestContext } from "../../../lib/communication/RequestContext";
import { FuncContextImpl } from "../api-lib-impl/FuncContextImpl";
import { AppCommandHandler } from "../AppCommandHandler";
import { StatelessFuncRequest, StatelessFuncResponse } from "./dtos";

export class StatelessFuncCommandHandler extends AppCommandHandler {
    handleAppCommand(payload: StatelessFuncRequest, ctx?: RequestContext): void {
        const app = this.apps.getApp(payload.appId)
        if (!app) {
            return
        }

        const statelessFunc = app.func[payload.sfunc]
        statelessFunc.func(
            this.lib,
            (payload.paramsJson ? JSON.parse(payload.paramsJson) : null) as never,
            new FuncContextImpl(payload.persistentLocalClientId, payload.requestId, payload.requestingUserId, this.lib.responseSender),
        )

        const response: StatelessFuncResponse = {
            general: {}
        }

        if (payload.requestId) {
            const responseSenderPayload = this.lib.responseSender.getAndRemoveResponse()
            if (responseSenderPayload) {
                response.general.responseSender = responseSenderPayload
            }
        }

        response.general.entityFuncInvokes = this.lib.entityFunc.getAndRemoveInvocations()

        ctx?.respond(JSON.stringify(response))
    }
}
