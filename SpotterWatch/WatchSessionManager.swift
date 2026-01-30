import Foundation
import WatchConnectivity

@MainActor
class WatchSessionManager: NSObject, ObservableObject {
    static let shared = WatchSessionManager()

    @Published var hasActiveSession = false
    @Published var duration: TimeInterval = 0
    @Published var heartRate: Double?
    @Published var climbCount: Int = 0
    @Published var sendCount: Int = 0
    @Published var gymName: String?

    private var session: WCSession?

    override init() {
        super.init()

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedHeartRate: String {
        guard let hr = heartRate else { return "--" }
        return String(format: "%.0f", hr)
    }
}

// MARK: - WCSessionDelegate

extension WatchSessionManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch WCSession activation error: \(error)")
        } else {
            print("Watch WCSession activated")
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            self.handleMessage(message)
        }
    }

    @MainActor
    private func handleMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }

        switch type {
        case "sessionStart":
            hasActiveSession = true
            duration = 0
            climbCount = 0
            sendCount = 0
            heartRate = nil
            gymName = message["gymName"] as? String

        case "sessionUpdate":
            if let dur = message["duration"] as? TimeInterval {
                duration = dur
            }
            if let hr = message["heartRate"] as? Double {
                heartRate = hr
            }
            if let climbs = message["climbCount"] as? Int {
                climbCount = climbs
            }
            if let sends = message["sendCount"] as? Int {
                sendCount = sends
            }
            if let gym = message["gymName"] as? String {
                gymName = gym
            }

        case "sessionEnd":
            hasActiveSession = false
            duration = 0
            climbCount = 0
            sendCount = 0
            heartRate = nil
            gymName = nil

        default:
            break
        }
    }
}
