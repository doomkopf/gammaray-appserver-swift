@available(macOS 10.15, *)
final class CommandProcessor: ReceptionListener, Sendable {
    private let jsonDecoder = StringJSONDecoder()
    private let resultCallbacks: ResultCallbacks

    init(resultCallbacks: ResultCallbacks) {
        self.resultCallbacks = resultCallbacks
    }

    func onReceived(source: ReceptionSource, frame: String) {
        let cmd: Command
        do {
            cmd = try jsonDecoder.decode(Command.self, frame)
        } catch {
            print("CommandProcessor: Error deserializing json=\(frame), error=\(error)")
            return
        }

        Task {
            if let id = cmd.id {
                if let callback = await resultCallbacks.remove(id) {
                    callback(RequestResult(error: nil, data: cmd.pl))
                    return
                }
            }

            // later further handling for CommandHandlers
            print("Should never get here for now")
        }
    }
}
