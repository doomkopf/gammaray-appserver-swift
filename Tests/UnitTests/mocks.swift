@testable import Gammaray

struct NoopScheduledTask: ScheduledTask {
    func setFunc(_ taskFunc: @escaping ScheduledTaskFunc) async {
    }
    func setFuncNotAwaiting(_ taskFunc: @escaping ScheduledTaskFunc) {
    }
    func cancel() async {
    }
}

struct NoopScheduler: Scheduler {
    func scheduleOnce(millis: Int64, taskFunc: @escaping ScheduledTaskFunc) {
    }
    func scheduleInterval(millis: Int64) -> ScheduledTask {
        NoopScheduledTask()
    }
}

struct NoopGammarayProtocolRequest: GammarayProtocolRequest {
    func respond(payload: String) async {
    }
    func cancel() async {
    }
}

struct NoopCache<K: Hashable, V>: Cache {
    func setListener(_ listener: any CacheListener<K, V>) {
    }
    func put(key: K, value: V) {
    }
    func get(key: K) -> V? {
        nil
    }
    func remove(_ key: K) -> V? {
        nil
    }
    func removeAnyEntry() -> CacheEntry<V>? {
        nil
    }
    func forEachEntry(fun: (K, V) -> Void) {
    }
    var size: Int {
        0
    }
    func cleanup() {
    }
    func clear() {
    }
}

struct SimpleEntityId: EntityId {
    let value: String
}

struct NoopGammarayPersistentSession: GammarayPersistentSession {
    func send(payload: String) {
    }
    func assignUserId(userId: EntityId) {
    }
    func getUserId() -> EntityId? {
        nil
    }
}

struct NoopNodeJsFuncResponseHandler: NodeJsFuncResponseHandler {
    func handle(response: NodeJsFuncResponse, ctx: RequestContext) async {
    }
}
