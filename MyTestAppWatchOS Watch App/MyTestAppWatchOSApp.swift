import SwiftUI

@main
struct MyTestAppWatchOS_Watch_AppApp: App {
    @StateObject private var timerModel = TimerModel()
    @StateObject private var connectivityManager = ConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerModel)
                .environmentObject(connectivityManager)
                .onReceive(connectivityManager.$receivedTimerData) { timerData in
                    handleReceivedTimerData(timerData)
                }
                .onReceive(NotificationCenter.default.publisher(for: .timerCommand)) { notification in
                    handleTimerCommand(notification)
                }
        }
    }

    // MARK: - Handle Received Timer Data
    private func handleReceivedTimerData(_ timerData: TimerData?) {
        guard let timerData = timerData else { return }

        // Sync timer model with received data
        timerModel.syncFrom(timerData)
    }

    // MARK: - Handle Timer Commands
    private func handleTimerCommand(_ notification: Notification) {
        guard let command = notification.userInfo?["command"] as? String else { return }

        switch command {
        case "start":
            if timerModel.state != .running {
                timerModel.start()
            }
        case "pause":
            if timerModel.state == .running {
                timerModel.pause()
            }
        case "stop":
            timerModel.stop()
        default:
            break
        }
    }
}
