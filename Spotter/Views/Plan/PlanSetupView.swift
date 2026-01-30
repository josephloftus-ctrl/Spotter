import SwiftUI
import SwiftData

struct PlanSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var planName = ""
    @State private var daysPerWeek = 3
    @State private var days: [DayEntry] = []
    @State private var notes = ""
    @State private var expandedDayId: UUID?

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

    private var canSave: Bool {
        !planName.isEmpty && !days.isEmpty && days.contains { !$0.exercises.isEmpty }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Plan Details
                        planDetailsSection

                        // Training Days
                        trainingDaysSection

                        // Notes
                        notesSection

                        // Save button
                        SpotterButton("Create Plan", icon: "checkmark", style: .primary) {
                            savePlan()
                        }
                        .disabled(!canSave)
                        .opacity(canSave ? 1.0 : 0.5)
                        .padding(.top, Spacing.md)
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, Spacing.xl)
                }
            }
            .navigationTitle("Create Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.spotterTextSecondary)
                    }
                }
            }
            .onAppear {
                if days.isEmpty {
                    addDay()
                }
            }
        }
    }

    private var planDetailsSection: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader("Plan Details")

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Plan Name")
                        .font(.spotterCaptionMedium)
                        .foregroundStyle(Color.spotterTextSecondary)

                    GlassTextField(placeholder: "e.g., Upper/Lower Split", text: $planName)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Days Per Week")
                        .font(.spotterCaptionMedium)
                        .foregroundStyle(Color.spotterTextSecondary)

                    GlassEffectContainer(spacing: Spacing.sm) {
                        HStack(spacing: Spacing.sm) {
                            ForEach(1...7, id: \.self) { num in
                                Button {
                                    daysPerWeek = num
                                    HapticManager.selection()
                                } label: {
                                    Text("\(num)")
                                        .font(.spotterBodyMedium)
                                        .foregroundStyle(daysPerWeek == num ? .white : Color.spotterTextSecondary)
                                        .frame(width: 40, height: 40)
                                }
                                .buttonStyle(.glass(daysPerWeek == num ? .regular.tint(.spotterPrimary).interactive() : .clear.interactive()))
                            }
                        }
                    }
                }
            }
        }
    }

    private var trainingDaysSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader("Training Days", subtitle: "\(days.count) configured")

            ForEach($days) { $day in
                dayCard(day: $day)
            }

            Button {
                addDay()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Add Training Day")
                        .font(.spotterBodyMedium)
                }
                .foregroundStyle(Color.spotterPrimary)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Color.spotterPrimaryMuted)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            }
        }
    }

    private func dayCard(day: Binding<DayEntry>) -> some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Day header
                HStack {
                    GlassTextField(placeholder: "Day Name", text: day.name)
                        .font(.spotterHeadline)

                    Spacer()

                    Button {
                        withAnimation(SpotterAnimation.quick) {
                            if expandedDayId == day.wrappedValue.id {
                                expandedDayId = nil
                            } else {
                                expandedDayId = day.wrappedValue.id
                            }
                        }
                    } label: {
                        Image(systemName: expandedDayId == day.wrappedValue.id ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.spotterTextMuted)
                    }
                }

                if expandedDayId == day.wrappedValue.id {
                    SpotterDivider()

                    // Exercises
                    VStack(spacing: Spacing.sm) {
                        ForEach(day.exercises) { $exercise in
                            exerciseRow(exercise: $exercise, day: day)
                        }
                    }

                    // Add exercise button
                    Button {
                        day.wrappedValue.exercises.append(
                            ExerciseEntry(name: "", sets: 3, reps: "8-12")
                        )
                        HapticManager.selection()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Exercise")
                        }
                        .font(.spotterCaptionMedium)
                        .foregroundStyle(Color.spotterPrimary)
                    }
                    .padding(.top, Spacing.xs)
                } else {
                    // Collapsed preview
                    Text("\(day.wrappedValue.exercises.filter { !$0.name.isEmpty }.count) exercises")
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)
                }
            }
        }
    }

    private func exerciseRow(exercise: Binding<ExerciseEntry>, day: Binding<DayEntry>) -> some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                TextField("Exercise name", text: exercise.name)
                    .font(.spotterBody)
                    .foregroundStyle(Color.spotterText)
                    .padding(Spacing.sm)
                    .background(Color.spotterSurface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))

                Button {
                    day.wrappedValue.exercises.removeAll { $0.id == exercise.wrappedValue.id }
                    HapticManager.selection()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.spotterError)
                }
            }

            HStack(spacing: Spacing.md) {
                // Sets
                HStack(spacing: Spacing.xs) {
                    Text("Sets:")
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)

                    HStack(spacing: 0) {
                        Button {
                            if exercise.wrappedValue.sets > 1 {
                                exercise.wrappedValue.sets -= 1
                                HapticManager.selection()
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.spotterTextSecondary)
                                .frame(width: 28, height: 28)
                                .background(Color.spotterSurface)
                        }

                        Text("\(exercise.wrappedValue.sets)")
                            .font(.spotterBodyMedium)
                            .foregroundStyle(Color.spotterText)
                            .frame(width: 32)

                        Button {
                            if exercise.wrappedValue.sets < 10 {
                                exercise.wrappedValue.sets += 1
                                HapticManager.selection()
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.spotterTextSecondary)
                                .frame(width: 28, height: 28)
                                .background(Color.spotterSurface)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xs))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.xs)
                            .strokeBorder(Color.spotterBorder, lineWidth: BorderWidth.thin)
                    )
                }

                Spacer()

                // Reps
                HStack(spacing: Spacing.xs) {
                    Text("Reps:")
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)

                    TextField("8-12", text: exercise.reps)
                        .font(.spotterBody)
                        .foregroundStyle(Color.spotterText)
                        .frame(width: 60)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.spotterSurface)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xs))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.xs)
                                .strokeBorder(Color.spotterBorder, lineWidth: BorderWidth.thin)
                        )
                }
            }
        }
        .padding(Spacing.sm)
        .background(Color.spotterSurface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
    }

    private var notesSection: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader("Notes", subtitle: "Optional")

                GlassTextField(placeholder: "Any notes about this plan...", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
    }

    private func addDay() {
        let dayNumber = days.count + 1
        let newDay = DayEntry(
            name: "Day \(dayNumber)",
            exercises: [ExerciseEntry(name: "", sets: 3, reps: "8-12")]
        )
        days.append(newDay)
        expandedDayId = newDay.id
        HapticManager.selection()
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
