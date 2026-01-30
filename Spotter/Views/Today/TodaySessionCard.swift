import SwiftUI

struct TodaySessionCard: View {
    let planDay: PlanDay

    var body: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader("Today's Plan", subtitle: "\(planDay.sortedExercises.count) exercises")

                VStack(spacing: 0) {
                    ForEach(Array(planDay.sortedExercises.enumerated()), id: \.element.id) { index, exercise in
                        exerciseRow(exercise, index: index + 1)

                        if index < planDay.sortedExercises.count - 1 {
                            SpotterDivider()
                                .padding(.leading, 40)
                        }
                    }
                }
            }
        }
    }

    private func exerciseRow(_ exercise: PlannedExercise, index: Int) -> some View {
        HStack(spacing: Spacing.sm) {
            // Exercise number badge
            Text("\(index)")
                .font(.spotterCaptionMedium)
                .foregroundStyle(Color.spotterTextMuted)
                .frame(width: 24, height: 24)
                .background(Color.spotterSurface)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.exerciseName)
                    .font(.spotterBodyMedium)
                    .foregroundStyle(Color.spotterText)

                Text(exercise.displayPrescription)
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextMuted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.spotterTextMuted)
        }
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    let planDay = PlanDay(name: "Day A - Squat Focus", orderIndex: 0)

    return TodaySessionCard(planDay: planDay)
        .padding()
        .background(Color.spotterBackground)
}
