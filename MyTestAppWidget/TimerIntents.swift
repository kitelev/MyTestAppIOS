import AppIntents
import Foundation
import ActivityKit

// MARK: - Pause Timer Intent
struct PauseTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Pause Timer"

    func perform() async throws -> some IntentResult {
        // Send notification to main app to pause timer
        NotificationCenter.default.post(
            name: Notification.Name("PauseTimerFromWidget"),
            object: nil
        )

        // Update Live Activity
        if let activity = Activity<TimerActivityAttributes>.activities.first {
            let updatedState = TimerActivityAttributes.ContentState(
                elapsedTime: activity.content.state.elapsedTime,
                state: .paused,
                startTime: nil
            )

            await activity.update(
                ActivityContent(
                    state: updatedState,
                    staleDate: nil
                )
            )
        }

        return .result()
    }
}

// MARK: - Resume Timer Intent
struct ResumeTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Resume Timer"

    func perform() async throws -> some IntentResult {
        // Send notification to main app to resume timer
        NotificationCenter.default.post(
            name: Notification.Name("ResumeTimerFromWidget"),
            object: nil
        )

        // Update Live Activity
        if let activity = Activity<TimerActivityAttributes>.activities.first {
            let updatedState = TimerActivityAttributes.ContentState(
                elapsedTime: activity.content.state.elapsedTime,
                state: .running,
                startTime: Date().addingTimeInterval(-activity.content.state.elapsedTime)
            )

            await activity.update(
                ActivityContent(
                    state: updatedState,
                    staleDate: nil
                )
            )
        }

        return .result()
    }
}

// MARK: - Stop Timer Intent
struct StopTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Timer"

    func perform() async throws -> some IntentResult {
        // Send notification to main app to stop timer
        NotificationCenter.default.post(
            name: Notification.Name("StopTimerFromWidget"),
            object: nil
        )

        // End Live Activity
        for activity in Activity<TimerActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        return .result()
    }
}
