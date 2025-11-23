import WidgetKit
import SwiftUI
import ActivityKit
import AppIntents

// MARK: - Widget Extension
struct TimerSyncWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.4))
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.white)
                        Text("Timer")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    TimerTextView(startTime: context.state.startTime,
                                  pausedTime: context.state.elapsedTime,
                                  isPaused: context.state.state == .paused)
                        .font(.largeTitle.monospacedDigit())
                        .foregroundColor(.white)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Button(intent: StopTimerIntent()) {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.red)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        if context.state.state == .running {
                            Button(intent: PauseTimerIntent()) {
                                Label("Pause", systemImage: "pause.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        } else if context.state.state == .paused {
                            Button(intent: ResumeTimerIntent()) {
                                Label("Resume", systemImage: "play.fill")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.white)
            } compactTrailing: {
                TimerTextView(startTime: context.state.startTime,
                              pausedTime: context.state.elapsedTime,
                              isPaused: context.state.state == .paused)
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.white)
                    .frame(width: 60)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Lock Screen View
struct LockScreenView: View {
    let context: ActivityViewContext<TimerActivityAttributes>

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.white)
                    Text("Timer")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                TimerTextView(startTime: context.state.startTime,
                              pausedTime: context.state.elapsedTime,
                              isPaused: context.state.state == .paused)
                    .font(.system(size: 40, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)

                HStack {
                    if context.state.state == .running {
                        Button(intent: PauseTimerIntent()) {
                            Label("Pause", systemImage: "pause.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    } else if context.state.state == .paused {
                        Button(intent: ResumeTimerIntent()) {
                            Label("Resume", systemImage: "play.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }

                    Button(intent: StopTimerIntent()) {
                        Label("Stop", systemImage: "stop.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            }
            .padding()

            Spacer()
        }
    }
}

// MARK: - Timer Text View
struct TimerTextView: View {
    let startTime: Date?
    let pausedTime: TimeInterval
    let isPaused: Bool

    var body: some View {
        if isPaused {
            Text(TimerModel.formatTime(pausedTime))
        } else if let startTime = startTime {
            Text(timerInterval: startTime...Date.distantFuture,
                 pauseTime: nil,
                 countsDown: false,
                 showsHours: true)
        } else {
            Text("00:00.0")
        }
    }
}
