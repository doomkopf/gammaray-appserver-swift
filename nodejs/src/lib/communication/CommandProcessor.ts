import { ReceptionListener } from "../connection/ReceptionListener"
import { ReceptionSource } from "../connection/ReceptionSource"
import { CommandContext } from "./CommandContext"
import { CommandHandler } from "./CommandHandler"
import { Command } from "./communication"

export class CommandProcessor implements ReceptionListener {
    constructor(
        private readonly commandHandlers: Map<number, CommandHandler>,
    ) {
    }

    onReceived(source: ReceptionSource, frame: string) {
        let cmd: Command
        try {
            cmd = JSON.parse(frame)
        } catch (err) {
            console.error("Error parsing command from frame", err)
            return
        }

        if (!cmd.cmd) {
            console.log(`Received invalid commmand: ${frame}`)
            return
        }

        const handler = this.commandHandlers.get(cmd.cmd)
        if (!handler) {
            console.log(`Unknown command: ${cmd.cmd}`)
            return
        }

        handler.handle(cmd.pl, cmd.id ? new CommandContext(source, cmd.id) : undefined)
    }
}
