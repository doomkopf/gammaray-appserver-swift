import { CommandContext } from "../../lib/communication/CommandContext"
import { CommandHandler } from "../../lib/communication/CommandHandler"
import { AppLib } from "./AppLib"
import { Apps } from "./Apps"

export abstract class AppCommandHandler implements CommandHandler {
    constructor(
        protected readonly apps: Apps,
        protected readonly lib: AppLib,
    ) {
    }

    handle(payload: string, ctx?: CommandContext): void {
        this.handleAppCommand(JSON.parse(payload), ctx)
    }

    abstract handleAppCommand(payload: unknown, ctx?: CommandContext): void
}
