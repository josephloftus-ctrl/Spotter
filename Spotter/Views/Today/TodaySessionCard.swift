import SwiftUI

struct TodaySessionCard: View {
    let planDay: PlanDay

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Today's Plan")
                .font(.spotterLabel)
                .foregroundStyle(Color.spotterTextSecondary)

            VStack(spacing: 0) {
                ForEach(planDay.sortedExercises) { exercise in
                    exerciseRow(exercise)
                }
            }
        }
    }

    private func exerciseRow(_ exercise: PlannedExercise) -> some View {
        HStack {
            Text(exercise.exerciseName)
                .font(.spotterBody)
                .foregroundStyle(Color.spotterText)
            Spacer()
            Text(exercise.displayPrescription)
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)
        }
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    let planDay = PlanDay(name: "Day A - Squat Focus", orderIndex: 0)

    return TodaySessionCard(planDay: planDay)
        .padding()
}
