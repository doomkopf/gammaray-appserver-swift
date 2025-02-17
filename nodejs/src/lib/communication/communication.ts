export interface Command {
    pl: string
    cmd?: number
    id?: string
}

export function responseCommand(id: string, pl: string): Command {
    return { id, pl }
}
