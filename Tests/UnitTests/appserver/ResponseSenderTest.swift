import XCTest

@testable import Gammaray

final class ResponseSenderTest: XCTestCase {
    func testSend() async {
        actor GammarayProtocolRequestMock: GammarayProtocolRequest {
            var respondPayload: String?

            func respond(payload: String) {
                respondPayload = payload
            }

            func cancel() {
            }
        }

        struct CacheMock: Cache {
            let request = GammarayProtocolRequestMock()

            func setListener(_ listener: any CacheListener<GammarayProtocolRequest>) {
            }

            func put(key: String, value: V) {
            }

            func get(key: String) -> V? {
                nil
            }

            func remove(_ key: String) -> V? {
                request
            }

            func removeAnyEntry() -> CacheEntry<V>? {
                nil
            }

            func forEachEntry(fun: (String, V) -> Void) {
            }

            var size: Int {
                0
            }

            func cleanup() {
            }

            func clear() {
            }
        }

        let cache = CacheMock()
        let subject = ResponseSender(
            scheduler: NoopScheduler(),
            requestsCache: cache
        )

        await subject.send(requestId: "id", objJson: "thePayload")

        let respondPayload = await cache.request.respondPayload

        XCTAssertEqual("thePayload", respondPayload)
    }

    func testGenerateUniqueIds() async {
        let subject = ResponseSender(
            scheduler: NoopScheduler(),
            requestsCache: NoopCache<GammarayProtocolRequest>()
        )

        var ids = Set<RequestId>()
        for _ in 0..<999999 {
            ids.insert(await subject.addRequest(request: NoopGammarayProtocolRequest()))
        }

        XCTAssertEqual(999999, ids.count)
    }

    func testInitSchedulesCacheCleanup() async {
        actor ScheduledTaskMock: ScheduledTask {
            var taskFunc: ScheduledTaskFunc?

            func setFunc(_ taskFunc: @escaping ScheduledTaskFunc) {
                self.taskFunc = taskFunc
            }

            nonisolated func setFuncNotAwaiting(_ taskFunc: @escaping ScheduledTaskFunc) {
                Task {
                    await setFunc(taskFunc)
                }
            }

            func cancel() {
            }
        }

        struct SchedulerMock: Scheduler {
            let task = ScheduledTaskMock()

            func scheduleOnce(millis: Int64, taskFunc: @escaping ScheduledTaskFunc) {
            }

            func scheduleInterval(millis: Int64) -> ScheduledTask {
                task
            }
        }

        actor CacheMutableState {
            var calledCleanup = false

            func setCalledCleanup() {
                calledCleanup = true
            }
        }

        struct CacheMock: Cache {
            let state = CacheMutableState()

            func setListener(_ listener: any CacheListener<GammarayProtocolRequest>) {
            }

            func put(key: String, value: V) {
            }

            func get(key: String) -> V? {
                nil
            }

            func remove(_ key: String) -> V? {
                nil
            }

            func removeAnyEntry() -> CacheEntry<V>? {
                nil
            }

            func forEachEntry(fun: (String, V) -> Void) {
            }

            var size: Int {
                0
            }

            func cleanup() {
                Task {
                    await state.setCalledCleanup()
                }
            }

            func clear() {
            }
        }

        let scheduler = SchedulerMock()
        let requestsCache = CacheMock()
        _ = ResponseSender(
            scheduler: scheduler,
            requestsCache: requestsCache
        )

        // await Task in ScheduledTaskMock.setFuncNotAwaiting
        await Task.yield()

        guard let taskFunc = await scheduler.task.taskFunc else {
            XCTFail("taskFunc not set")
            return
        }

        await taskFunc()

        // await Task in CacheMock.cleanup
        await Task.yield()

        let calledCleanup = await requestsCache.state.calledCleanup
        XCTAssertTrue(calledCleanup)
    }
}
