import { CommandHandler } from "../../lib/communication/CommandHandler"
import { CommandProcessor } from "../../lib/communication/CommandProcessor"
import { Receiver } from "../../lib/connection/Receiver"

class CommunicationTest
{
  private readonly rec: Receiver

  constructor()
  {
    const commandHandlers = new Map<number, CommandHandler>()
    commandHandlers.set(1, {
      handle(payload, ctx)
      {
        ctx?.respond(payload)
      },
    })

    this.rec = new Receiver(1234, new CommandProcessor(commandHandlers))
  }

  async shutdown()
  {
    await this.rec.shutdown()
  }
}

function exec()
{
  const test = new CommunicationTest()

  process.on("SIGTERM", async () =>
  {
    await test.shutdown()
  })
}

exec()
