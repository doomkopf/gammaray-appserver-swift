import { CommandContext } from "../../../lib/communication/CommandContext";
import { GammarayApp } from "../api/core";
import { AppCommandHandler } from "../AppCommandHandler";
import { NodeJsSetAppErrorResponseType, NodeJsSetAppRequest, NodeJsSetAppResponse } from "./dtos";

export class SetAppCommandHandler extends AppCommandHandler {
    handleAppCommand(payload: NodeJsSetAppRequest, ctx?: CommandContext): void {
        const response: NodeJsSetAppResponse = {}

        try {
            const app: GammarayApp = eval(payload.code + "\napp;")
            this.apps.setApp(payload.id, app)
        } catch (error) {
            response.error = {
                type: NodeJsSetAppErrorResponseType.SCRIPT_EVALUATION,
                message: error.message,
            }
        }

        ctx?.respond(JSON.stringify(response))
    }
}
