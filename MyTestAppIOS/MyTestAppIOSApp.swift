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
                    syncToWatch()
                    connectivityManager.sendCommand("pause")
                    liveActivityManager.updateActivity(with: timerModel)
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ResumeTimerFromWidget"))) { _ in
                    timerModel.start()
                    syncToWatch()
                    connectivityManager.sendCommand("start")
                    liveActivityManager.updateActivity(with: timerModel)
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("StopTimerFromWidget"))) { _ in
                    timerModel.stop()
                    syncToWatch()
                    connectivityManager.sendCommand("stop")
                    liveActivityManager.endActivity()
                }
        }
    }

    // MARK: - Handle Received Timer Data
    private func handleReceivedTimerData(_ timerData: TimerData?) {
        guard let timerData = timerData else { return }

        // Sync timer model with received data
        timerModel.syncFrom(timerData)

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

    // MARK: - Sync to Watch
    private func syncToWatch() {
        let timerData = TimerData(
            state: timerModel.state,
            elapsedTime: timerModel.elapsedTime,
            startTime: timerModel.startTime,
            pausedTime: timerModel.pausedTime
        )
        connectivityManager.sendTimerData(timerData)
    }
}
