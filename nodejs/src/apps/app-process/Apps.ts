import { CommandHandler } from "../../lib/communication/CommandHandler"
import { CommandProcessor } from "../../lib/communication/CommandProcessor"
import { Receiver } from "../../lib/connection/Receiver"
import { LoggerFactory } from "../../lib/logging/LoggerFactory"
import { GammarayApp } from "./api/core"
import { AppLib } from "./AppLib"
import { AppDefinitionCommandHandler } from "./command-handlers/AppDefinitionCommandHandler"
import { EntityFuncCommandHandler } from "./command-handlers/EntityFuncCommandHandler"
import { SetAppCommandHandler } from "./command-handlers/SetAppCommandHandler"
import { StatelessFuncCommandHandler } from "./command-handlers/StatelessFuncCommandHandler"
import { Commands } from "./Commands"
import { LOCAL_PORT } from "./constants"

export class Apps {
    private readonly rec: Receiver
    private readonly apps = new Map<string, GammarayApp>()

    constructor(
        loggerFactory: LoggerFactory,
        lib: AppLib,
    ) {
        const commandHandlers = new Map<number, CommandHandler>()
        commandHandlers.set(Commands.ENTITY_FUNC, new EntityFuncCommandHandler(loggerFactory, this, lib))
        commandHandlers.set(Commands.STATELESS_FUNC, new StatelessFuncCommandHandler(loggerFactory, this, lib))
        commandHandlers.set(Commands.APP_DEFINITION, new AppDefinitionCommandHandler(loggerFactory, this, lib))
        commandHandlers.set(Commands.SET_APP, new SetAppCommandHandler(loggerFactory, this, lib))

        this.rec = new Receiver(LOCAL_PORT, new CommandProcessor(commandHandlers))
    }

    setApp(id: string, appRoot: GammarayApp) {
        this.apps.set(id, appRoot)
    }

    getApp(id: string): GammarayApp | undefined {
        return this.apps.get(id)
    }

    async shutdown() {
        await this.rec.shutdown()
    }
}
