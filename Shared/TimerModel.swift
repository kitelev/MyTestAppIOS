import Foundation
import Combine

// MARK: - Timer State
public enum TimerState: String, Codable {
    case idle
    case running
    case paused

    var displayText: String {
        switch self {
        case .idle:
            return "Ready"
        case .running:
            return "Running"
        case .paused:
            return "Paused"
        }
    }
}

// MARK: - Timer Model
public class TimerModel: ObservableObject {
    @Published public var state: TimerState = .idle
    @Published public var elapsedTime: TimeInterval = 0
    @Published public var startTime: Date?
    @Published public var pausedTime: TimeInterval = 0

    private var timer: Timer?

    public init() {}

    // MARK: - Timer Controls
    public func start() {
        guard state != .running else { return }

        if state == .paused {
            // Resume from paused state
            startTime = Date().addingTimeInterval(-pausedTime)
        } else {
            // Start fresh
            startTime = Date()
            elapsedTime = 0
            pausedTime = 0
        }

        state = .running
        startTimer()
    }

    public func pause() {
        guard state == .running else { return }

        pausedTime = elapsedTime
        state = .paused
        stopTimer()
    }

    public func stop() {
        state = .idle
        elapsedTime = 0
        startTime = nil
        pausedTime = 0
        stopTimer()
    }

    // MARK: - Synchronization
    public func syncFrom(_ timerData: TimerData) {
        // Stop current timer first
        stopTimer()

        // Update all properties
        state = timerData.state
        elapsedTime = timerData.elapsedTime
        startTime = timerData.startTime
        pausedTime = timerData.pausedTime

        // Start timer if running
        if state == .running {
            startTimer()
        }
    }

    // MARK: - Timer Management
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateElapsedTime()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }

    // MARK: - Formatting
    public static func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 10)

        if hours > 0 {
            return String(format: "%02d:%02d:%02d.%d", hours, minutes, seconds, milliseconds)
        } else {
            return String(format: "%02d:%02d.%d", minutes, seconds, milliseconds)
        }
    }
}

// MARK: - Timer Data for Synchronization
public struct TimerData: Codable {
    public let state: TimerState
    public let elapsedTime: TimeInterval
    public let startTime: Date?
    public let pausedTime: TimeInterval

    public init(state: TimerState, elapsedTime: TimeInterval, startTime: Date?, pausedTime: TimeInterval) {
        self.state = state
        self.elapsedTime = elapsedTime
        self.startTime = startTime
        self.pausedTime = pausedTime
    }
}
