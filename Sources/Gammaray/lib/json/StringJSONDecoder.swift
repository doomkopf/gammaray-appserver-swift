import Foundation

struct StringJSONDecoder {
    private let dec = JSONDecoder()

    func decode<T: Decodable>(_ type: T.Type, _ str: String) throws -> T {
        if type == String.self {
            return str as! T
        }
        return try dec.decode(type, from: str.data(using: .utf8)!)
    }
}
