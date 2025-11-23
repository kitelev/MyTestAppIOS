import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerModel: TimerModel
    @EnvironmentObject var connectivityManager: ConnectivityManager

    var body: some View {
        VStack(spacing: 10) {
            // Timer Display
            Text(TimerModel.formatTime(timerModel.elapsedTime))
                .font(.system(size: 28, weight: .regular, design: .monospaced))
                .foregroundColor(.primary)
                .padding(.top, 10)

            // Timer State
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(timerModel.state.displayText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)

            // Control Buttons
            HStack(spacing: 10) {
                if timerModel.state == .running {
                    // Pause Button
                    Button(action: pauseTimer) {
                        Image(systemName: "pause.fill")
                            .font(.title2)
                            .frame(width: 60, height: 60)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                } else {
                    // Start Button
                    Button(action: startTimer) {
                        Image(systemName: "play.fill")
                            .font(.title2)
                            .frame(width: 60, height: 60)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }

                // Stop Button
                Button(action: stopTimer) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(timerModel.state == .idle)
                .opacity(timerModel.state == .idle ? 0.5 : 1.0)
            }

            // iPhone Connection Status
            HStack {
                Image(systemName: connectivityManager.isReachable ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                    .font(.caption2)
                    .foregroundColor(connectivityManager.isReachable ? .green : .gray)
                Text(connectivityManager.isReachable ? "Connected" : "Not Connected")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 5)
        }
        .navigationTitle("Timer")
        .navigationBarTitleDisplayMode(.inline)
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
        syncToPhone()
        connectivityManager.sendCommand("start")
    }

    private func pauseTimer() {
        timerModel.pause()
        syncToPhone()
        connectivityManager.sendCommand("pause")
    }

    private func stopTimer() {
        timerModel.stop()
        syncToPhone()
        connectivityManager.sendCommand("stop")
    }

    private func syncToPhone() {
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
    }
}
