import Foundation

func decodeStringToJson<T: Decodable>(_ dec: JSONDecoder, _ type: T.Type, _ str: String) throws -> T
{
    guard let data = str.data(using: .utf8) else {
        throw AppserverError.General("Invalid string encoding")
    }
    return try dec.decode(type, from: data)
}
