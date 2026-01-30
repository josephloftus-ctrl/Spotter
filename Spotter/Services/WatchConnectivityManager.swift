import Foundation
import WatchConnectivity

@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var isWatchAppInstalled = false
    @Published var isReachable = false

    private var session: WCSession?

    override init() {
        super.init()

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    // MARK: - Send Session Updates

    func sendSessionUpdate(
        duration: TimeInterval,
        heartRate: Double?,
        climbCount: Int,
        sendCount: Int,
        gymName: String?
    ) {
        guard let session = session, session.isReachable else {
            print("Watch not reachable")
            return
        }

        var message: [String: Any] = [
            "type": "sessionUpdate",
            "duration": duration,
            "climbCount": climbCount,
            "sendCount": sendCount
        ]

        if let heartRate = heartRate {
            message["heartRate"] = heartRate
        }

        if let gymName = gymName {
            message["gymName"] = gymName
        }

        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending watch message: \(error)")
        }
    }

    func sendSessionStart(gymName: String) {
        guard let session = session, session.isReachable else { return }

        let message: [String: Any] = [
            "type": "sessionStart",
            "gymName": gymName
        ]

        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending session start: \(error)")
        }
    }

    func sendSessionEnd() {
        guard let session = session, session.isReachable else { return }

        let message: [String: Any] = [
            "type": "sessionEnd"
        ]

        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending session end: \(error)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable
        }

        if let error = error {
            print("WCSession activation error: \(error)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
        // Reactivate for iOS
        session.activate()
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
        }
        print("Watch reachability changed: \(session.isReachable)")
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }
}
