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
    @State private var showingExercisePicker = false

    // For quick sessions - exercises added on the fly
    @State private var quickSessionExercises: [Exercise] = []

    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    init(planDay: PlanDay?) {
        self.planDay = planDay
        self._session = State(initialValue: Session(
            planDayName: planDay?.name
        ))
    }

    private var isQuickSession: Bool {
        planDay == nil
    }

    private var plannedExercises: [PlannedExercise] {
        planDay?.sortedExercises ?? []
    }

    private var currentPlannedExercise: PlannedExercise? {
        guard !isQuickSession else { return nil }
        guard currentExerciseIndex < plannedExercises.count else { return nil }
        return plannedExercises[currentExerciseIndex]
    }

    private var currentQuickExercise: Exercise? {
        guard isQuickSession else { return nil }
        guard currentExerciseIndex < quickSessionExercises.count else { return nil }
        return quickSessionExercises[currentExerciseIndex]
    }

    private var currentExerciseName: String? {
        if isQuickSession {
            return currentQuickExercise?.name
        } else {
            return currentPlannedExercise?.exerciseName
        }
    }

    private var hasCurrentExercise: Bool {
        currentExerciseName != nil
    }

    private var setsForCurrentExercise: [SetEntry] {
        guard let name = currentExerciseName else { return [] }
        return session.sets.filter { $0.exercise?.name == name }
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
                    .foregroundStyle(Color.spotterBorder)

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        if hasCurrentExercise {
                            // Current Exercise
                            currentExerciseSection

                            // Completed Sets
                            if !setsForCurrentExercise.isEmpty {
                                completedSetsSection
                            }

                            // Quick session: buttons to navigate or add more
                            if isQuickSession {
                                quickSessionControls
                            }
                        } else if isQuickSession {
                            // No exercise selected yet - prompt to add one
                            addExercisePrompt
                        } else {
                            // Plan complete
                            noExercisesView
                        }
                    }
                    .padding(Spacing.md)
                }

                Divider()
                    .foregroundStyle(Color.spotterBorder)

                // Log Set Button
                if hasCurrentExercise {
                    logSetButton
                }
            }
            .background(Color.spotterBackground)
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
                    .disabled(session.sets.isEmpty)
                }
            }
            .sheet(isPresented: $showingSessionComplete) {
                SessionCompleteView(session: session) {
                    dismiss()
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(exercises: exercises) { exercise in
                    addQuickExercise(exercise)
                }
            }
            .onAppear {
                modelContext.insert(session)
            }
        }
    }

    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Elapsed")
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextSecondary)
                Text(elapsedTime)
                    .font(.spotterHeadline)
                    .foregroundStyle(Color.spotterText)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                Text("Sets Logged")
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextSecondary)
                Text("\(session.sets.count)")
                    .font(.spotterHeadline)
                    .foregroundStyle(Color.spotterText)
            }
        }
        .padding(Spacing.md)
    }

    private var elapsedTime: String {
        DateFormatters.formatDuration(Date().timeIntervalSince(startTime))
    }

    private var currentExerciseSection: some View {
        VStack(spacing: Spacing.lg) {
            // Exercise Name
            VStack(spacing: Spacing.xs) {
                Text(currentExerciseName ?? "")
                    .font(.spotterTitle)
                    .foregroundStyle(Color.spotterText)

                // Set Counter
                if isQuickSession {
                    Text("Set \(setsForCurrentExercise.count + 1)")
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextSecondary)
                } else {
                    Text("Set \(currentSetNumber) of \(targetSets)")
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextSecondary)
                }
            }

            Divider()
                .foregroundStyle(Color.spotterBorder)

            // Weight Stepper
            weightStepper

            // Reps Stepper
            repsStepper

            Divider()
                .foregroundStyle(Color.spotterBorder)

            // RPE Selector
            rpeSelector
        }
        .padding(Spacing.md)
        .background(Color.spotterSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var weightStepper: some View {
        HStack {
            Button {
                weight = max(0, weight - 5)
                HapticManager.selection()
            } label: {
                Image(systemName: "minus.circle")
                    .font(.title)
                    .foregroundStyle(Color.spotterPrimary)
            }

            VStack(spacing: Spacing.xs) {
                Text("\(Int(weight))")
                    .font(.spotterLargeNumber)
                    .foregroundStyle(Color.spotterText)
                Text("lbs")
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextSecondary)
            }
            .frame(minWidth: 120)

            Button {
                weight += 5
                HapticManager.selection()
            } label: {
                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundStyle(Color.spotterPrimary)
            }
        }
    }

    private var repsStepper: some View {
        HStack {
            Button {
                reps = max(1, reps - 1)
                HapticManager.selection()
            } label: {
                Image(systemName: "minus.circle")
                    .font(.title)
                    .foregroundStyle(Color.spotterPrimary)
            }

            VStack(spacing: Spacing.xs) {
                Text("\(reps)")
                    .font(.spotterLargeNumber)
                    .foregroundStyle(Color.spotterText)
                Text("reps")
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextSecondary)
            }
            .frame(minWidth: 120)

            Button {
                reps += 1
                HapticManager.selection()
            } label: {
                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundStyle(Color.spotterPrimary)
            }
        }
    }

    private var rpeSelector: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("RPE (optional)")
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)

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
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(selectedRPE == rpe ? Color.spotterPrimary : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .strokeBorder(Color.spotterBorder, lineWidth: selectedRPE == rpe ? 0 : BorderWidth.thin)
                            )
                            .foregroundStyle(selectedRPE == rpe ? .white : Color.spotterText)
                    }
                }
            }
        }
    }

    private var completedSetsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Completed Sets")
                .font(.spotterLabel)
                .foregroundStyle(Color.spotterTextSecondary)

            VStack(spacing: 0) {
                ForEach(Array(setsForCurrentExercise.enumerated()), id: \.element.id) { index, set in
                    HStack {
                        Text("Set \(index + 1)")
                            .font(.spotterBody)
                            .foregroundStyle(Color.spotterTextSecondary)
                        Spacer()
                        Text("\(set.displayWeight) × \(set.reps)")
                            .font(.spotterBody)
                            .foregroundStyle(Color.spotterText)
                        if let rpe = set.rpe {
                            Text("@\(rpe)")
                                .font(.spotterCaption)
                                .foregroundStyle(Color.spotterTextSecondary)
                        }
                    }
                    .padding(.vertical, Spacing.sm)

                    if index < setsForCurrentExercise.count - 1 {
                        Divider()
                            .foregroundStyle(Color.spotterBorder)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.spotterBorder, lineWidth: BorderWidth.thin)
        )
    }

    private var quickSessionControls: some View {
        HStack(spacing: Spacing.md) {
            // Previous exercise
            if currentExerciseIndex > 0 {
                Button {
                    currentExerciseIndex -= 1
                    selectedRPE = nil
                    HapticManager.selection()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                        .font(.spotterBody)
                        .foregroundStyle(Color.spotterPrimary)
                }
            }

            Spacer()

            // Next exercise or add new
            if currentExerciseIndex < quickSessionExercises.count - 1 {
                Button {
                    currentExerciseIndex += 1
                    selectedRPE = nil
                    HapticManager.selection()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                        .font(.spotterBody)
                        .foregroundStyle(Color.spotterPrimary)
                }
            } else {
                Button {
                    showingExercisePicker = true
                } label: {
                    Label("Add Exercise", systemImage: "plus")
                        .font(.spotterBody)
                        .foregroundStyle(Color.spotterPrimary)
                }
            }
        }
        .padding(.horizontal, Spacing.sm)
    }

    private var addExercisePrompt: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "dumbbell")
                .font(.system(size: 48))
                .foregroundStyle(Color.spotterTextSecondary)

            Text("Start your workout")
                .font(.spotterHeadline)
                .foregroundStyle(Color.spotterText)

            Text("Add an exercise to begin logging sets")
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)

            Button {
                showingExercisePicker = true
            } label: {
                Label("Add Exercise", systemImage: "plus")
                    .font(.spotterHeadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .background(Color.spotterPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            }
        }
        .padding(Spacing.xl)
    }

    private var noExercisesView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color.spotterSuccess)
            Text("All exercises complete!")
                .font(.spotterHeadline)
                .foregroundStyle(Color.spotterText)
            Text("Tap Finish to wrap up your session")
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)
        }
        .padding(Spacing.lg)
    }

    private var logSetButton: some View {
        Button {
            logSet()
        } label: {
            Text("Log Set")
                .font(.spotterHeadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(Color.spotterPrimary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .padding(Spacing.md)
    }

    private func logSet() {
        let exercise: Exercise

        if isQuickSession {
            guard let quickExercise = currentQuickExercise else { return }
            exercise = quickExercise
        } else {
            guard let plannedExercise = currentPlannedExercise else { return }
            exercise = findOrCreateExercise(named: plannedExercise.exerciseName)
        }

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

        // For planned sessions, advance to next set or exercise
        if !isQuickSession {
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
        } else {
            // For quick sessions, just reset RPE
            selectedRPE = nil
        }
    }

    private func addQuickExercise(_ exercise: Exercise) {
        quickSessionExercises.append(exercise)
        currentExerciseIndex = quickSessionExercises.count - 1
        selectedRPE = nil
        HapticManager.selection()
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

// MARK: - Exercise Picker

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let exercises: [Exercise]
    let onSelect: (Exercise) -> Void

    @State private var searchText = ""

    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var groupedExercises: [(ExerciseModality, [Exercise])] {
        let grouped = Dictionary(grouping: filteredExercises) { $0.modality }
        return grouped.sorted { $0.key.displayName < $1.key.displayName }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedExercises, id: \.0) { modality, exercises in
                    Section(modality.displayName) {
                        ForEach(exercises) { exercise in
                            Button {
                                onSelect(exercise)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: exercise.modality.icon)
                                        .foregroundStyle(Color.spotterTextSecondary)

                                    VStack(alignment: .leading, spacing: Spacing.xs) {
                                        Text(exercise.name)
                                            .font(.spotterBody)
                                            .foregroundStyle(Color.spotterText)

                                        if !exercise.muscleGroups.isEmpty {
                                            Text(exercise.muscleGroups.joined(separator: ", "))
                                                .font(.spotterCaption)
                                                .foregroundStyle(Color.spotterTextSecondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
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
