import { ReceptionListener } from "../connection/ReceptionListener"
import { ReceptionSource } from "../connection/ReceptionSource"
import { CommandHandler } from "./CommandHandler"
import { Command } from "./communication"
import { RequestContext } from "./RequestContext"

export class CommandProcessor implements ReceptionListener
{
  constructor(
    private readonly commandHandlers: Map<number, CommandHandler>,
  )
  {
  }

  onReceived(source: ReceptionSource, frame: string)
  {
    const cmd: Command = JSON.parse(frame)

    if (!cmd.cmd)
    {
      console.log(`Received invalid commmand: ${frame}`)
      return
    }

    const handler = this.commandHandlers.get(cmd.cmd)
    if (!handler)
    {
      console.log(`Unknown command: ${cmd.cmd}`)
      return
    }

    handler.handle(cmd.pl, cmd.id ? new RequestContext(source, cmd.id) : undefined)
  }
}
