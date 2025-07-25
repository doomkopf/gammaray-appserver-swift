import { CommandContext } from "../../../lib/communication/CommandContext";
import { RequestContextImpl } from "../api-lib-impl/RequestContextImpl";
import { AppCommandHandler } from "../AppCommandHandler";
import { NodeJsFuncRequest, NodeJsStatelessFuncResponse } from "./dtos";
import { buildNodeJsFuncResponse } from "./util";

export class StatelessFuncCommandHandler extends AppCommandHandler {
    handleAppCommand(payload: NodeJsFuncRequest, ctx?: CommandContext): void {
        const app = this.apps.getApp(payload.appId)
        if (!app) {
            return
        }

        const statelessFunc = app.func[payload.fun]
        statelessFunc.func(
            this.lib,
            (payload.paramsJson ? JSON.parse(payload.paramsJson) : null) as never,
            new RequestContextImpl(
                this.lib.responseSender,
                payload.requestId,
                payload.requestingUserId,
                payload.clientRequestId,
            ),
        )

        const response: NodeJsStatelessFuncResponse = {
            general: buildNodeJsFuncResponse(this.lib)
        }

        ctx?.respond(JSON.stringify(response))
    }
}
