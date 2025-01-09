enum ConfigProperty: String {
    case dummy
    case nodeJsBinaryPath
}

private func defaultValue(_ configProperty: ConfigProperty) -> String {
    switch configProperty {
    case .dummy: "dummyDefaultValue"
    case .nodeJsBinaryPath: "pathNotConfigured"
    }
}

class Config {
    private let config: [ConfigProperty: String]

    init(reader: ResourceFileReader) throws {
        let configString = try reader.readStringFile(name: "gammaray", ext: "cfg")
        let lines = configString.split(separator: "\n")

        var config: [ConfigProperty: String] = [:]
        for line in lines {
            let keyValue = line.split(separator: "=", maxSplits: 1)
            let keySubstring = keyValue[0]
            guard let key = ConfigProperty.init(rawValue: String(keySubstring)) else {
                throw AppserverError.General("Unknown config property: \(keySubstring)")
            }
            config[key] = String(keyValue[1])
        }

        self.config = config
    }

    func get(_ configProperty: ConfigProperty) -> String {
        if let configValue = config[configProperty] {
            return configValue
        }

        return defaultValue(configProperty)
    }
}
