import Foundation

struct StringJSONEncoder {
    private let enc = JSONEncoder()

    func encode(_ object: Encodable) -> String {
        if object is String {
            return object as! String
        }
        return String(data: try! enc.encode(object), encoding: .utf8)!
    }
}
