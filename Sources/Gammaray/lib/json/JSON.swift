import Foundation

enum JSON: Codable {
    case string(String)
    case number(Double)
    case object([String: JSON])
    case array([JSON])
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
        } else if let x = try? container.decode(Double.self) {
            self = .number(x)
        } else if let x = try? container.decode(Bool.self) {
            self = .bool(x)
        } else if let x = try? container.decode([String: JSON].self) {
            self = .object(x)
        } else if let x = try? container.decode([JSON].self) {
            self = .array(x)
        } else {
            self = .null
        }
    }

    static func fromString(_ str: String) throws -> JSON {
        try decodeStringToJson(JSONDecoder(), JSON.self, str)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x): try container.encode(x)
        case .number(let x): try container.encode(x)
        case .bool(let x): try container.encode(x)
        case .object(let x): try container.encode(x)
        case .array(let x): try container.encode(x)
        case .null: try container.encodeNil()
        }
    }

    func buildString() -> String {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            return "{}"
        }
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
