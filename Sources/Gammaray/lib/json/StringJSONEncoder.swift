import Foundation

struct StringJSONEncoder {
    private let enc = JSONEncoder()

    func encode(_ object: Encodable) -> String {
        String(data: try! enc.encode(object), encoding: .utf8)!
    }
}
