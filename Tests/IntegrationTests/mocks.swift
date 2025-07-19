@testable import Gammaray

struct NoopGammarayProtocolRequest: GammarayProtocolRequest {
    func respond(payload: String) async {
    }
    func cancel() async {
    }
}
