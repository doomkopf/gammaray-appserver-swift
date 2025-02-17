import { CommandHandler } from "../../lib/communication/CommandHandler"
import { RequestContext } from "../../lib/communication/RequestContext"
import { AppLib } from "./AppLib"
import { Apps } from "./Apps"

export abstract class AppCommandHandler implements CommandHandler {
    constructor(
        protected readonly apps: Apps,
        protected readonly lib: AppLib,
    ) {
    }

    handle(payload: string, ctx?: RequestContext): void {
        this.handleAppCommand(JSON.parse(payload), ctx)
    }

    abstract handleAppCommand(payload: unknown, ctx?: RequestContext): void
}
