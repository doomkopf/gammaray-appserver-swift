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
