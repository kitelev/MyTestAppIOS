import SwiftUI

@main
struct MyTestAppIOSApp: App {
    @StateObject private var timerModel = TimerModel()
    @StateObject private var connectivityManager = ConnectivityManager.shared
    @StateObject private var liveActivityManager = LiveActivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerModel)
                .environmentObject(connectivityManager)
                .environmentObject(liveActivityManager)
                .onReceive(connectivityManager.$receivedTimerData) { timerData in
                    handleReceivedTimerData(timerData)
                }
                .onReceive(NotificationCenter.default.publisher(for: .timerCommand)) { notification in
                    handleTimerCommand(notification)
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PauseTimerFromWidget"))) { _ in
                    timerModel.pause()
                    liveActivityManager.updateActivity(with: timerModel)
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ResumeTimerFromWidget"))) { _ in
                    timerModel.start()
                    liveActivityManager.updateActivity(with: timerModel)
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("StopTimerFromWidget"))) { _ in
                    timerModel.stop()
                    liveActivityManager.endActivity()
                }
        }
    }

    // MARK: - Handle Received Timer Data
    private func handleReceivedTimerData(_ timerData: TimerData?) {
        guard let timerData = timerData else { return }

        // Update local timer model with received data
        timerModel.state = timerData.state
        timerModel.elapsedTime = timerData.elapsedTime
        timerModel.startTime = timerData.startTime
        timerModel.pausedTime = timerData.pausedTime

        // Update Live Activity
        if timerData.state == .running || timerData.state == .paused {
            liveActivityManager.updateActivity(with: timerModel)
        } else {
            liveActivityManager.endActivity()
        }
    }

    // MARK: - Handle Timer Commands
    private func handleTimerCommand(_ notification: Notification) {
        guard let command = notification.userInfo?["command"] as? String else { return }

        switch command {
        case "start":
            if timerModel.state != .running {
                timerModel.start()
                liveActivityManager.startActivity(with: timerModel)
            }
        case "pause":
            if timerModel.state == .running {
                timerModel.pause()
                liveActivityManager.updateActivity(with: timerModel)
            }
        case "stop":
            timerModel.stop()
            liveActivityManager.endActivity()
        default:
            break
        }
    }
}
