import { CommandHandler } from "../../lib/communication/CommandHandler"
import { CommandProcessor } from "../../lib/communication/CommandProcessor"
import { Receiver } from "../../lib/connection/Receiver"
import { GammarayApp } from "./api/core"
import { AppLib } from "./AppLib"
import { AppDefinitionCommandHandler } from "./command-handlers/AppDefinitionCommandHandler"
import { EntityFuncCommandHandler } from "./command-handlers/EntityFuncCommandHandler"
import { SetAppCommandHandler } from "./command-handlers/SetAppCommandHandler"
import { StatelessFuncCommandHandler } from "./command-handlers/StatelessFuncCommandHandler"
import { Commands } from "./Commands"

export class Apps {
  private readonly rec: Receiver
  private readonly apps = new Map<string, GammarayApp>()

  constructor(
    lib: AppLib,
  ) {
    const commandHandlers = new Map<number, CommandHandler>()
    commandHandlers.set(Commands.ENTITY_FUNC, new EntityFuncCommandHandler(this, lib))
    commandHandlers.set(Commands.STATELESS_FUNC, new StatelessFuncCommandHandler(this, lib))
    commandHandlers.set(Commands.APP_DEFINITION, new AppDefinitionCommandHandler(this, lib))
    commandHandlers.set(Commands.SET_APP, new SetAppCommandHandler(this, lib))

    this.rec = new Receiver(1234, new CommandProcessor(commandHandlers))
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
