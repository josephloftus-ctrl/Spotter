import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let planDay: PlanDay?

    @State private var session: Session
    @State private var currentExerciseIndex = 0
    @State private var currentSetNumber = 1
    @State private var weight: Double = 135
    @State private var reps: Int = 5
    @State private var selectedRPE: Int? = nil
    @State private var startTime = Date()
    @State private var showingSessionComplete = false

    @Query private var exercises: [Exercise]

    init(planDay: PlanDay?) {
        self.planDay = planDay
        self._session = State(initialValue: Session(
            planDayName: planDay?.name
        ))
    }

    private var plannedExercises: [PlannedExercise] {
        planDay?.sortedExercises ?? []
    }

    private var currentPlannedExercise: PlannedExercise? {
        guard currentExerciseIndex < plannedExercises.count else { return nil }
        return plannedExercises[currentExerciseIndex]
    }

    private var setsForCurrentExercise: [SetEntry] {
        guard let exerciseName = currentPlannedExercise?.exerciseName else { return [] }
        return session.sets.filter { $0.exercise?.name == exerciseName }
    }

    private var targetSets: Int {
        currentPlannedExercise?.sets ?? 3
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                sessionHeader

                Divider()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Current Exercise
                        if let exercise = currentPlannedExercise {
                            currentExerciseSection(exercise)
                        } else {
                            noExercisesView
                        }

                        // Completed Sets
                        if !setsForCurrentExercise.isEmpty {
                            completedSetsSection
                        }
                    }
                    .padding()
                }

                Divider()

                // Log Set Button
                logSetButton
            }
            .navigationTitle(planDay?.name ?? "Quick Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Finish") {
                        finishSession()
                    }
                }
            }
            .sheet(isPresented: $showingSessionComplete) {
                SessionCompleteView(session: session) {
                    dismiss()
                }
            }
            .onAppear {
                modelContext.insert(session)
            }
        }
    }

    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Elapsed")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
                Text(elapsedTime)
                    .font(.spotterHeadline)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Sets Logged")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
                Text("\(session.sets.count)")
                    .font(.spotterHeadline)
            }
        }
        .padding()
    }

    private var elapsedTime: String {
        DateFormatters.formatDuration(Date().timeIntervalSince(startTime))
    }

    private func currentExerciseSection(_ exercise: PlannedExercise) -> some View {
        VStack(spacing: Spacing.md) {
            // Exercise Name
            Text(exercise.exerciseName)
                .font(.spotterTitle)

            // Set Counter
            Text("Set \(currentSetNumber) of \(targetSets)")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            // Weight Stepper
            weightStepper

            // Reps Stepper
            repsStepper

            // RPE Selector
            rpeSelector
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var weightStepper: some View {
        HStack {
            Button {
                weight = max(0, weight - 5)
                HapticManager.selection()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title)
            }

            VStack {
                Text("\(Int(weight))")
                    .font(.spotterLargeNumber)
                Text("lbs")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 120)

            Button {
                weight += 5
                HapticManager.selection()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
        }
    }

    private var repsStepper: some View {
        HStack {
            Button {
                reps = max(1, reps - 1)
                HapticManager.selection()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title)
            }

            VStack {
                Text("\(reps)")
                    .font(.spotterLargeNumber)
                Text("reps")
                    .font(.spotterCaption)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 120)

            Button {
                reps += 1
                HapticManager.selection()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
        }
    }

    private var rpeSelector: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("RPE (optional)")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            HStack(spacing: Spacing.sm) {
                ForEach([6, 7, 8, 9, 10], id: \.self) { rpe in
                    Button {
                        selectedRPE = selectedRPE == rpe ? nil : rpe
                        HapticManager.selection()
                    } label: {
                        Text("\(rpe)")
                            .font(.spotterBody)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(selectedRPE == rpe ? Color.spotterPrimaryFallback : Color.spotterSurfaceFallback)
                            .foregroundStyle(selectedRPE == rpe ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    }
                }
            }
        }
    }

    private var completedSetsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Completed Sets")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            ForEach(Array(setsForCurrentExercise.enumerated()), id: \.element.id) { index, set in
                HStack {
                    Text("Set \(index + 1)")
                        .font(.spotterBody)
                    Spacer()
                    Text("\(set.displayWeight) × \(set.reps)")
                        .font(.spotterBody)
                    if let rpe = set.rpe {
                        Text("@\(rpe)")
                            .font(.spotterCaption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, Spacing.xs)
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var noExercisesView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.spotterSuccessFallback)
            Text("All exercises complete!")
                .font(.spotterHeadline)
            Text("Tap Finish to wrap up your session")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var logSetButton: some View {
        Button {
            logSet()
        } label: {
            Text("Log Set")
                .font(.spotterHeadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.spotterPrimaryFallback)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .padding()
        .disabled(currentPlannedExercise == nil)
    }

    private func logSet() {
        guard let plannedExercise = currentPlannedExercise else { return }

        // Find or create exercise
        let exercise = findOrCreateExercise(named: plannedExercise.exerciseName)

        // Create set entry
        let setEntry = SetEntry(
            exercise: exercise,
            session: session,
            weight: weight,
            reps: reps,
            rpe: selectedRPE,
            orderIndex: session.sets.count
        )

        session.sets.append(setEntry)
        HapticManager.logSet()

        // Advance to next set or exercise
        if currentSetNumber >= targetSets {
            currentSetNumber = 1
            currentExerciseIndex += 1
            selectedRPE = nil

            if currentExerciseIndex >= plannedExercises.count {
                HapticManager.completeExercise()
            }
        } else {
            currentSetNumber += 1
        }
    }

    private func findOrCreateExercise(named name: String) -> Exercise {
        if let existing = exercises.first(where: { $0.name == name }) {
            return existing
        }

        let newExercise = Exercise(name: name)
        modelContext.insert(newExercise)
        return newExercise
    }

    private func finishSession() {
        session.duration = Date().timeIntervalSince(startTime)
        showingSessionComplete = true
    }
}

#Preview {
    ActiveSessionView(planDay: nil)
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
