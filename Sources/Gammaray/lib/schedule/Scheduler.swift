import Foundation

typealias ScheduledTaskFunc = @Sendable () async -> Void

@available(macOS 10.15, *)
actor ScheduledTask {
    private var _taskFunc: ScheduledTaskFunc?
    private var cancelled = false

    func setFunc(_ taskFunc: @escaping ScheduledTaskFunc) {
        _taskFunc = taskFunc
    }

    /// Helper method for e.g. classes that schedule internal behavior from the constructor.
    /// For most task scheduling cases it is not relevant to await for the func to be actually set in the task - it will be eventually.
    nonisolated func setFuncNotAwaiting(_ taskFunc: @escaping ScheduledTaskFunc) {
        Task {
            await setFunc(taskFunc)
        }
    }

    var taskFunc: ScheduledTaskFunc? {
        _taskFunc
    }

    var isCancelled: Bool {
        cancelled
    }

    func cancel() {
        cancelled = true
    }
}

@available(macOS 10.15, *)
final class Scheduler: Sendable {
    func scheduleOnce(millis: Int64, taskFunc: @escaping ScheduledTaskFunc) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + TimeInterval(floatLiteral: Double(millis) / 1000)
        ) {
            Task {
                await taskFunc()
            }
        }
    }

    func scheduleInterval(millis: Int64)
        -> ScheduledTask
    {
        let task = ScheduledTask()

        internalScheduleInterval(millis: millis, task: task)

        return task
    }

    private func internalScheduleInterval(millis: Int64, task: ScheduledTask) {
        Task {
            if await task.isCancelled {
                return
            }

            scheduleOnce(millis: millis) {
                await task.taskFunc!()
                self.internalScheduleInterval(millis: millis, task: task)
            }
        }
    }
}
