import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerModel: TimerModel
    @EnvironmentObject var connectivityManager: ConnectivityManager
    @EnvironmentObject var liveActivityManager: LiveActivityManager

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Timer Display
                Text(TimerModel.formatTime(timerModel.elapsedTime))
                    .font(.system(size: 60, weight: .thin, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding()

                // Timer State
                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                    Text(timerModel.state.displayText)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                // Control Buttons
                HStack(spacing: 30) {
                    if timerModel.state == .running {
                        // Pause Button
                        Button(action: pauseTimer) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 30))
                                .frame(width: 80, height: 80)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    } else {
                        // Start Button
                        Button(action: startTimer) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 30))
                                .frame(width: 80, height: 80)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }

                    // Stop Button
                    Button(action: stopTimer) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 30))
                            .frame(width: 80, height: 80)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .disabled(timerModel.state == .idle)
                    .opacity(timerModel.state == .idle ? 0.5 : 1.0)
                }
                .padding()

                Spacer()

                // Watch Connection Status
                HStack {
                    Image(systemName: connectivityManager.isReachable ? "applewatch.radiowaves.left.and.right" : "applewatch.slash")
                        .foregroundColor(connectivityManager.isReachable ? .green : .gray)
                    Text(connectivityManager.isReachable ? "Watch23 Connected" : "Watch Not Connected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Timer Sync")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var statusColor: Color {
        switch timerModel.state {
        case .idle:
            return .gray
        case .running:
            return .green
        case .paused:
            return .orange
        }
    }

    // MARK: - Actions
    private func startTimer() {
        timerModel.start()
        syncToWatch()
        connectivityManager.sendCommand("start")
        liveActivityManager.startActivity(with: timerModel)
    }

    private func pauseTimer() {
        timerModel.pause()
        syncToWatch()
        connectivityManager.sendCommand("pause")
        liveActivityManager.updateActivity(with: timerModel)
    }

    private func stopTimer() {
        timerModel.stop()
        syncToWatch()
        connectivityManager.sendCommand("stop")
        liveActivityManager.endActivity()
    }

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TimerModel())
            .environmentObject(ConnectivityManager.shared)
            .environmentObject(LiveActivityManager.shared)
    }
}
