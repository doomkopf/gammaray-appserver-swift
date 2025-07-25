enum ConfigProperty: String {
    case dummy
    case nodeJsBinaryPath
    case nodeJsAppApiRequestTimeoutMillis
    case nodeJsAppApiSendTimeoutMillis
    case nodeJsAppApiSendIntervalMillis
    case entityCacheEvictionTimeMillis
    case entityCacheMaxEntries
    case appScheduledTasksIntervalMillis
    case webserverPort
    case appDeploymentPassword
}

private func defaultValue(_ configProperty: ConfigProperty) -> String {
    switch configProperty {
    case .dummy: "dummyDefaultValue"
    case .nodeJsBinaryPath: "pathNotConfigured"
    case .nodeJsAppApiRequestTimeoutMillis: "4000"
    case .nodeJsAppApiSendTimeoutMillis: "3000"
    case .nodeJsAppApiSendIntervalMillis: "2000"
    case .entityCacheEvictionTimeMillis: "600000"
    case .entityCacheMaxEntries: "100000"
    case .appScheduledTasksIntervalMillis: "3000"
    case .webserverPort: "8080"
    case .appDeploymentPassword: "thisdefaultpasswordshouldnotbeused"
    }
}

struct Config {
    private let config: [ConfigProperty: String]

    init(reader: ResourceFileReader, customConfig: [ConfigProperty: String]) throws {
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

        for custom in customConfig {
            config[custom.key] = custom.value
        }

        self.config = config
    }

    func getString(_ configProperty: ConfigProperty) -> String {
        if let configValue = config[configProperty] {
            return configValue
        }

        return defaultValue(configProperty)
    }

    func getInt64(_ configProperty: ConfigProperty) -> Int64 {
        Int64(getString(configProperty)) ?? 0
    }

    func getInt(_ configProperty: ConfigProperty) -> Int {
        Int(getString(configProperty)) ?? 0
    }
}
