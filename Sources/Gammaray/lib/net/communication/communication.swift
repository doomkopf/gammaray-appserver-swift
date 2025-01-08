struct Command: Codable {
    let pl: String
    let cmd: Int?
    let id: String?
}

func requestCommand(cmd: Int, id: String, pl: String) -> Command {
    Command(pl: pl, cmd: cmd, id: id)
}
