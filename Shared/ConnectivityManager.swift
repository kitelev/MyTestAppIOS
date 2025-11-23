import Foundation
import Combine
#if os(iOS) || os(watchOS)
import WatchConnectivity
#endif

#if os(iOS) || os(watchOS)
// MARK: - Connectivity Manager
public class ConnectivityManager: NSObject, ObservableObject {
    public static let shared = ConnectivityManager()

    @Published public var isReachable = false
    @Published public var receivedTimerData: TimerData?

    private let session: WCSession

    private override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Send Timer Data
    public func sendTimerData(_ timerData: TimerData) {
        guard session.isReachable else {
            // Try to send via application context for offline sync
            sendViaApplicationContext(timerData)
            return
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(timerData)
            let message = ["timerData": data]

            session.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
                // Fallback to application context
                self.sendViaApplicationContext(timerData)
            }
        } catch {
            print("Error encoding timer data: \(error)")
        }
    }

    // MARK: - Send Command
    public func sendCommand(_ command: String) {
        guard session.isReachable else {
            print("Session not reachable")
            return
        }

        let message = ["command": command]
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending command: \(error.localizedDescription)")
        }
    }

    // MARK: - Application Context (for offline sync)
    private func sendViaApplicationContext(_ timerData: TimerData) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(timerData)
            let context = ["timerData": data]
            try session.updateApplicationContext(context)
        } catch {
            print("Error updating application context: \(error)")
        }
    }
}

// MARK: - WCSessionDelegate
extension ConnectivityManager: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Session activation failed: \(error.localizedDescription)")
            return
        }

        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }

        print("Session activated with state: \(activationState.rawValue)")
    }

    public func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    // MARK: - Receive Messages
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleReceivedMessage(message)
    }

    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handleReceivedMessage(message)
        replyHandler(["status": "received"])
    }

    // MARK: - Application Context
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleReceivedMessage(applicationContext)
    }

    // MARK: - Message Handling
    private func handleReceivedMessage(_ message: [String: Any]) {
        if let data = message["timerData"] as? Data {
            do {
                let decoder = JSONDecoder()
                let timerData = try decoder.decode(TimerData.self, from: data)
                DispatchQueue.main.async {
                    self.receivedTimerData = timerData
                }
            } catch {
                print("Error decoding timer data: \(error)")
            }
        }

        if let command = message["command"] as? String {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .timerCommand,
                    object: nil,
                    userInfo: ["command": command]
                )
            }
        }
    }

    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive")
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        print("Session deactivated")
        session.activate()
    }
    #endif
}

#else
// MARK: - Connectivity Manager Stub for macOS/Other Platforms
public class ConnectivityManager: ObservableObject {
    public static let shared = ConnectivityManager()

    @Published public var isReachable = false
    @Published public var receivedTimerData: TimerData?

    private init() {}

    public func sendTimerData(_ timerData: TimerData) {
        // Stub implementation for macOS
    }

    public func sendCommand(_ command: String) {
        // Stub implementation for macOS
    }
}
#endif

// MARK: - Notification Extension
extension Notification.Name {
    static let timerCommand = Notification.Name("timerCommand")
}
