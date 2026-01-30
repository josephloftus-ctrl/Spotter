import SwiftUI

struct WatchSessionView: View {
    @EnvironmentObject var sessionManager: WatchSessionManager

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Gym name header
                if let gymName = sessionManager.gymName {
                    Text(gymName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Duration - main metric
                VStack(spacing: 2) {
                    Text(sessionManager.formattedDuration)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .monospacedDigit()

                    Text("DURATION")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Stats row
                HStack(spacing: 16) {
                    // Heart rate
                    VStack(spacing: 4) {
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.red)
                            Text(sessionManager.formattedHeartRate)
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                        }
                        Text("BPM")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Divider()
                        .frame(height: 40)

                    // Climbs
                    VStack(spacing: 4) {
                        Text("\(sessionManager.climbCount)")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                        Text("CLIMBS")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Divider()
                        .frame(height: 40)

                    // Sends
                    VStack(spacing: 4) {
                        Text("\(sessionManager.sendCount)")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(.green)
                        Text("SENDS")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Climbing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let manager = WatchSessionManager.shared

    return WatchSessionView()
        .environmentObject(manager)
}
