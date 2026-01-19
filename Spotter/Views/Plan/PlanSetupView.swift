import SwiftUI
import SwiftData

struct PlanSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var planName = ""
    @State private var daysPerWeek = 3
    @State private var days: [DayEntry] = []
    @State private var notes = ""

    struct DayEntry: Identifiable {
        let id = UUID()
        var name: String
        var exercises: [ExerciseEntry]
    }

    struct ExerciseEntry: Identifiable {
        let id = UUID()
        var name: String
        var sets: Int
        var reps: String
    }

    var body: some View {
        NavigationStack {
            Form {
                // Plan Info
                Section("Plan Details") {
                    TextField("Plan Name", text: $planName)

                    Stepper("Days per week: \(daysPerWeek)", value: $daysPerWeek, in: 1...7)
                }

                // Days
                Section("Training Days") {
                    ForEach($days) { $day in
                        daySection(day: $day)
                    }

                    Button {
                        addDay()
                    } label: {
                        Label("Add Day", systemImage: "plus")
                    }
                }

                // Notes
                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Create Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlan()
                    }
                    .disabled(planName.isEmpty || days.isEmpty)
                }
            }
            .onAppear {
                if days.isEmpty {
                    // Add initial day
                    addDay()
                }
            }
        }
    }

    private func daySection(day: Binding<DayEntry>) -> some View {
        DisclosureGroup {
            ForEach(day.exercises) { $exercise in
                exerciseRow(exercise: $exercise)
            }

            Button {
                day.wrappedValue.exercises.append(ExerciseEntry(name: "", sets: 3, reps: "8-12"))
            } label: {
                Label("Add Exercise", systemImage: "plus")
                    .font(.spotterCaption)
            }
        } label: {
            TextField("Day Name", text: day.name)
                .font(.spotterHeadline)
        }
    }

    private func exerciseRow(exercise: Binding<ExerciseEntry>) -> some View {
        VStack(spacing: Spacing.sm) {
            TextField("Exercise Name", text: exercise.name)

            HStack {
                Stepper("Sets: \(exercise.wrappedValue.sets)", value: exercise.sets, in: 1...10)

                Spacer()

                TextField("Reps", text: exercise.reps)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    private func addDay() {
        let dayNumber = days.count + 1
        days.append(DayEntry(
            name: "Day \(dayNumber)",
            exercises: [ExerciseEntry(name: "", sets: 3, reps: "8-12")]
        ))
    }

    private func savePlan() {
        // Deactivate existing plans
        let descriptor = FetchDescriptor<TrainingPlan>()
        if let existingPlans = try? modelContext.fetch(descriptor) {
            for plan in existingPlans {
                plan.isActive = false
            }
        }

        // Create new plan
        let plan = TrainingPlan(
            name: planName,
            daysPerWeek: daysPerWeek,
            isActive: true,
            notes: notes.isEmpty ? nil : notes
        )

        modelContext.insert(plan)

        // Create days and exercises
        for (index, dayEntry) in days.enumerated() {
            let planDay = PlanDay(
                name: dayEntry.name,
                orderIndex: index,
                plan: plan
            )

            modelContext.insert(planDay)

            for (exerciseIndex, exerciseEntry) in dayEntry.exercises.enumerated() {
                guard !exerciseEntry.name.isEmpty else { continue }

                let plannedExercise = PlannedExercise(
                    exerciseName: exerciseEntry.name,
                    sets: exerciseEntry.sets,
                    reps: exerciseEntry.reps,
                    orderIndex: exerciseIndex,
                    planDay: planDay
                )

                modelContext.insert(plannedExercise)
            }
        }

        HapticManager.notification(.success)
        dismiss()
    }
}

#Preview {
    PlanSetupView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
