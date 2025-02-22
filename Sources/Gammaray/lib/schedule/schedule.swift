import Foundation

func gammaraySleep(_ millis: Int64) async {
    await withCheckedContinuation { c in
        DispatchQueue.main.asyncAfter(
            deadline: .now() + TimeInterval(floatLiteral: Double(millis) / 1000)
        ) {
            c.resume()
        }
    }
}
