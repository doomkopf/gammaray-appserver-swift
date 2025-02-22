import { RequestContext } from "../../../lib/communication/RequestContext";
import { FuncContextImpl } from "../api-lib-impl/FuncContextImpl";
import { AppCommandHandler } from "../AppCommandHandler";
import { NodeJsStatelessFuncRequest, NodeJsStatelessFuncResponse } from "./dtos";
import { buildNodeJsFuncResponse } from "./util";

export class StatelessFuncCommandHandler extends AppCommandHandler {
    handleAppCommand(payload: NodeJsStatelessFuncRequest, ctx?: RequestContext): void {
        const app = this.apps.getApp(payload.appId)
        if (!app) {
            return
        }

        const statelessFunc = app.func[payload.sfunc]
        statelessFunc.func(
            this.lib,
            (payload.paramsJson ? JSON.parse(payload.paramsJson) : null) as never,
            new FuncContextImpl(payload.requestId, payload.requestingUserId, this.lib.responseSender),
        )

        const response: NodeJsStatelessFuncResponse = {
            general: buildNodeJsFuncResponse(this.lib)
        }

        ctx?.respond(JSON.stringify(response))
    }
}
