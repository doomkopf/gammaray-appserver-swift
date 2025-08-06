import { CommandContext } from "../../lib/communication/CommandContext"
import { CommandHandler } from "../../lib/communication/CommandHandler"
import { Logger } from "../../lib/logging/Logger"
import { LoggerFactory } from "../../lib/logging/LoggerFactory"
import { LogLevel } from "../../lib/logging/LogLevel"
import { AppLib } from "./AppLib"
import { Apps } from "./Apps"

export abstract class AppCommandHandler implements CommandHandler {
    protected readonly log: Logger

    constructor(
        loggerFactory: LoggerFactory,
        protected readonly apps: Apps,
        protected readonly lib: AppLib,
    ) {
        this.log = loggerFactory.createForClass(AppCommandHandler)
    }

    handle(payload: string, ctx?: CommandContext): void {
        try {
            this.handleAppCommand(JSON.parse(payload), ctx)
        } catch (err) {
            this.log.log(LogLevel.ERROR, "", err)
        }
    }

    abstract handleAppCommand(payload: unknown, ctx?: CommandContext): void
}
