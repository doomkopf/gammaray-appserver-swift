import Foundation

func currentTimeMillis() -> Int64 {
    Int64(Date().timeIntervalSince1970) * 1000
}

func randomUuidString() -> String {
    UUID().uuidString
}
