import SwiftUI
import WatchConnectivity

@main
struct SpotterWatchApp: App {
    @StateObject private var sessionManager = WatchSessionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var sessionManager: WatchSessionManager

    var body: some View {
        if sessionManager.hasActiveSession {
            WatchSessionView()
        } else {
            WatchIdleView()
        }
    }
}
