actor RequestIdGenerator {
    private let localHost: String
    private let localPort: Int

    private var n = 0

    init(localHost: String, localPort: Int) {
        self.localHost = localHost
        self.localPort = localPort
    }

    func generate() -> String {
        "\(localHost):\(localPort):\(nextNumber())"
    }

    private func nextNumber() -> Int {
        if n >= 999999 {
            n = 0
        }

        n += 1

        return n
    }
}
