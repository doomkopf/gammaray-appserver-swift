import Foundation

final class StringJSONDecoder: Sendable {
    private let dec = JSONDecoder()

    func decode<T: Decodable>(_ type: T.Type, _ str: String) throws -> T {
        try dec.decode(type, from: str.data(using: .utf8)!)
    }
}
