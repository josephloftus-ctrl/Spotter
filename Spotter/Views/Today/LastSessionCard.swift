import SwiftUI

struct LastSessionCard: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Last Session")
                    .font(.spotterLabel)
                    .foregroundStyle(Color.spotterTextSecondary)
                Spacer()
                Text(DateFormatters.formatRelativeDate(session.date))
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextSecondary)
            }

            if let planDayName = session.planDayName {
                Text(planDayName)
                    .font(.spotterHeadline)
                    .foregroundStyle(Color.spotterText)
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
            .padding(.top, Spacing.xs)
        }
        .padding(Spacing.md)
        .background(Color.spotterSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.spotterHeadline)
                .foregroundStyle(Color.spotterText)
            Text(label)
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)
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
