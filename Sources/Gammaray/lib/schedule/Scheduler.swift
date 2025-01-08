import Foundation

actor ScheduledTask {
    private var cancelled = false

    var isCancelled: Bool {
        cancelled
    }

    func cancel() {
        cancelled = true
    }
}

@available(macOS 10.15, *)
final class Scheduler: Sendable {
    func scheduleOnce(millis: Int64, callback: @Sendable @escaping () async -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + TimeInterval(floatLiteral: Double(millis) / 1000)
        ) {
            Task {
                await callback()
            }
        }
    }

    func scheduleInterval(millis: Int64, callback: @Sendable @escaping () async -> Void)
        -> ScheduledTask
    {
        let task = ScheduledTask()

        internalScheduleInterval(millis: millis, task: task, callback: callback)

        return task
    }

    private func internalScheduleInterval(
        millis: Int64, task: ScheduledTask, callback: @Sendable @escaping () async -> Void
    ) {
        Task {
            if await task.isCancelled {
                return
            }

            scheduleOnce(millis: millis) {
                await callback()
                self.internalScheduleInterval(millis: millis, task: task, callback: callback)
            }
        }
    }
}
