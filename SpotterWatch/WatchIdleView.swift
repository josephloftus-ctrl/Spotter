import SwiftUI

struct WatchIdleView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 40))
                .foregroundStyle(.cyan)

            VStack(spacing: 4) {
                Text("Spotter")
                    .font(.headline)

                Text("No active session")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Start a climbing session on your iPhone")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    WatchIdleView()
}
