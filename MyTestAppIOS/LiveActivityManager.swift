import Foundation
import ActivityKit
import SwiftUI
import Combine

// MARK: - Timer Activity Attributes
public struct TimerActivityAttributes: ActivityAttributes {
    public typealias TimerStatus = ContentState

    public struct ContentState: Codable, Hashable {
        public var elapsedTime: TimeInterval
        public var state: TimerState
        public var startTime: Date?

        public init(elapsedTime: TimeInterval, state: TimerState, startTime: Date?) {
            self.elapsedTime = elapsedTime
            self.state = state
            self.startTime = startTime
        }
    }

    public init() {}
}

// MARK: - Live Activity Manager
public class LiveActivityManager: ObservableObject {
    public static let shared = LiveActivityManager()

    private var currentActivity: Activity<TimerActivityAttributes>?

    private init() {}

    // MARK: - Start Activity
    public func startActivity(with timerModel: TimerModel) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Activities are not enabled")
            return
        }

        // End existing activity if any
        endActivity()

        let attributes = TimerActivityAttributes()
        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: timerModel.elapsedTime,
            state: timerModel.state,
            startTime: timerModel.startTime
        )

        let activityContent = ActivityContent(
            state: contentState,
            staleDate: nil
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
            print("Live Activity started")
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }

    // MARK: - Update Activity
    public func updateActivity(with timerModel: TimerModel) {
        guard let activity = currentActivity else { return }

        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: timerModel.elapsedTime,
            state: timerModel.state,
            startTime: timerModel.startTime
        )

        let activityContent = ActivityContent(
            state: contentState,
            staleDate: nil
        )

        Task {
            await activity.update(activityContent)
        }
    }

    // MARK: - End Activity
    public func endActivity() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            await MainActor.run {
                self.currentActivity = nil
            }
        }
    }
}
