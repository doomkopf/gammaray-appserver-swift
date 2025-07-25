import { CommandContext } from "./CommandContext"

export interface CommandHandler {
    handle(payload: string, ctx?: CommandContext): void
}
