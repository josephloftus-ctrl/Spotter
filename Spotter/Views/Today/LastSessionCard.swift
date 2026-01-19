import SwiftUI

struct LastSessionCard: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Last Session")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(DateFormatters.formatRelativeDate(session.date))
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
            }

            if let planDayName = session.planDayName {
                Text(planDayName)
                    .font(.spotterHeadline)
            }

            HStack(spacing: Spacing.lg) {
                statItem(
                    value: "\(session.exerciseCount)",
                    label: "exercises"
                )

                if let duration = session.duration {
                    statItem(
                        value: DateFormatters.formatDuration(duration),
                        label: "duration"
                    )
                }

                if let rpe = session.sessionRPE {
                    statItem(
                        value: "\(rpe)/5",
                        label: "feel"
                    )
                }
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.spotterHeadline)
            Text(label)
                .font(.spotterCaption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let session = Session(
        planDayName: "Day A - Squat Focus",
        duration: 3600,
        sessionRPE: 4
    )

    return LastSessionCard(session: session)
        .padding()
}
