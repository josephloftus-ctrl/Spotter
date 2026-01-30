import SwiftUI

struct LastSessionCard: View {
    let session: Session

    var body: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Last Session")
                            .font(.spotterCaptionMedium)
                            .foregroundStyle(Color.spotterTextSecondary)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        if let planDayName = session.planDayName {
                            Text(planDayName)
                                .font(.spotterHeadline)
                                .foregroundStyle(Color.spotterText)
                        }
                    }

                    Spacer()

                    Text(DateFormatters.formatRelativeDate(session.date))
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xxs)
                        .background(Color.spotterSurface)
                        .clipShape(Capsule())
                }

                SpotterDivider()

                // Stats row
                HStack(spacing: 0) {
                    sessionStat(
                        value: "\(session.exerciseCount)",
                        label: "Exercises",
                        icon: "dumbbell.fill"
                    )

                    if let duration = session.duration {
                        Spacer()
                        sessionStat(
                            value: DateFormatters.formatDuration(duration),
                            label: "Duration",
                            icon: "clock.fill"
                        )
                    }

                    if let rpe = session.sessionRPE {
                        Spacer()
                        sessionStat(
                            value: "\(rpe)/5",
                            label: "Feel",
                            icon: "heart.fill"
                        )
                    }
                }
            }
        }
    }

    private func sessionStat(value: String, label: String, icon: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.spotterTextMuted)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.spotterBodyMedium)
                    .foregroundStyle(Color.spotterText)
                Text(label)
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextMuted)
            }
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
        .background(Color.spotterBackground)
}
