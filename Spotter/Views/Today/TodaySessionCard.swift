import SwiftUI

struct TodaySessionCard: View {
    let planDay: PlanDay

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Today's Plan")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            ForEach(planDay.sortedExercises) { exercise in
                exerciseRow(exercise)
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func exerciseRow(_ exercise: PlannedExercise) -> some View {
        HStack {
            Text(exercise.exerciseName)
                .font(.spotterBody)
            Spacer()
            Text(exercise.displayPrescription)
                .font(.spotterCaption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    let planDay = PlanDay(name: "Day A - Squat Focus", orderIndex: 0)

    return TodaySessionCard(planDay: planDay)
        .padding()
}
