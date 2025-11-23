# MyTestAppIOS

iOS and watchOS timer application with Live Activities support.

## Features

- **iOS Timer App**: Full-featured timer with elegant UI
- **watchOS Companion**: Synchronized timer for Apple Watch
- **Live Activities**: Timer display on Lock Screen and Dynamic Island (iPhone 14 Pro+)
- **Real-time Sync**: Bidirectional synchronization between iPhone and Apple Watch via WatchConnectivity
- **Interactive Widgets**: Pause, resume, and stop timer directly from Lock Screen

## Requirements

- iOS 16.0+
- watchOS 9.0+
- Xcode 15.0+
- Swift 5.0+

## Architecture

### Shared Components
- `TimerModel.swift`: Core timer logic and state management
- `ConnectivityManager.swift`: WatchConnectivity session management

### iOS App
- `MyTestAppIOSApp.swift`: Main app entry point
- `ContentView.swift`: Timer interface
- `LiveActivityManager.swift`: Live Activities management

### watchOS App
- `MyTestAppWatchOSApp.swift`: Watch app entry point
- `ContentView.swift`: Watch timer interface

### Widget Extension
- `TimerSyncWidget.swift`: Live Activity UI (Lock Screen, Dynamic Island)
- `TimerIntents.swift`: Interactive widget controls

## How It Works

1. **Timer States**: The timer has three states - idle, running, and paused
2. **Synchronization**: Any state change on either device is instantly synced to the other
3. **Live Activities**: When timer starts on iPhone, a Live Activity appears on Lock Screen
4. **Interactive Controls**: Users can pause/resume/stop timer from Lock Screen widgets

## Building

1. Open `MyTestAppIOS.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run on your iPhone and Apple Watch

## Configuration

Live Activities are enabled via `INFOPLIST_KEY_NSSupportsLiveActivities = YES` in build settings.

## License

MIT License
