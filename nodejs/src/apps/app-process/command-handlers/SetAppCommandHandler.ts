import { RequestContext } from "../../../lib/communication/RequestContext";
import { GammarayApp } from "../api/core";
import { AppCommandHandler } from "../AppCommandHandler";
import { NodeJsSetAppRequest, NodeJsSetAppResponse } from "./dtos";

export class SetAppCommandHandler extends AppCommandHandler {
    handleAppCommand(payload: NodeJsSetAppRequest, ctx?: RequestContext): void {
        const app: GammarayApp = eval(payload.code + "\napp;")
        this.apps.setApp(payload.id, app)

        const response: NodeJsSetAppResponse = {}
        ctx?.respond(JSON.stringify(response))
    }
}
