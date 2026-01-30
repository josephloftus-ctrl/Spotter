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
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?
    @State private var showSetLogged = false

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

    private var sessionProgress: Double {
        guard !isQuickSession else { return 0 }
        let totalSets = plannedExercises.reduce(0) { $0 + $1.sets }
        guard totalSets > 0 else { return 0 }
        return Double(session.sets.count) / Double(totalSets)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Session Header
                    sessionHeader
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.sm)

                    ScrollView {
                        VStack(spacing: Spacing.lg) {
                            if hasCurrentExercise {
                                // Current Exercise Card
                                currentExerciseSection

                                // Completed Sets
                                if !setsForCurrentExercise.isEmpty {
                                    completedSetsSection
                                }

                                // Quick session navigation
                                if isQuickSession {
                                    quickSessionControls
                                }
                            } else if isQuickSession {
                                addExercisePrompt
                            } else {
                                allCompleteView
                            }
                        }
                        .padding(Spacing.md)
                        .padding(.bottom, 100)
                    }
                }

                // Fixed bottom action
                VStack {
                    Spacer()
                    if hasCurrentExercise {
                        logSetButton
                    }
                }
            }
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

                ToolbarItem(placement: .principal) {
                    Text(planDay?.name ?? "Quick Session")
                        .font(.spotterHeadline)
                        .foregroundStyle(Color.spotterText)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        finishSession()
                    } label: {
                        Text("Finish")
                            .font(.spotterLabel)
                            .foregroundStyle(session.sets.isEmpty ? Color.spotterTextMuted : Color.spotterPrimary)
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
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }

    private var sessionHeader: some View {
        HStack(spacing: Spacing.lg) {
            // Timer
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Duration")
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextMuted)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text(formatElapsedTime())
                    .font(.spotterTimer)
                    .foregroundStyle(Color.spotterText)
                    .monospacedDigit()
            }

            Spacer()

            // Sets counter
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text("Sets")
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextMuted)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text("\(session.sets.count)")
                    .font(.spotterMediumNumber)
                    .foregroundStyle(Color.spotterText)
                    .contentTransition(.numericText())
                    .animation(SpotterAnimation.bounce, value: session.sets.count)
            }

            // Progress ring (for planned sessions)
            if !isQuickSession {
                ProgressRing(
                    progress: sessionProgress,
                    lineWidth: 5,
                    size: 44
                )
            }
        }
        .padding(Spacing.md)
        .background(Color.spotterSurfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var currentExerciseSection: some View {
        SpotterCard {
            VStack(spacing: Spacing.lg) {
                // Exercise name and set indicator
                VStack(spacing: Spacing.xs) {
                    Text(currentExerciseName ?? "")
                        .font(.spotterTitleSecondary)
                        .foregroundStyle(Color.spotterText)
                        .multilineTextAlignment(.center)

                    if isQuickSession {
                        Text("Set \(setsForCurrentExercise.count + 1)")
                            .font(.spotterCaptionMedium)
                            .foregroundStyle(Color.spotterTextMuted)
                    } else {
                        HStack(spacing: Spacing.xs) {
                            ForEach(0..<targetSets, id: \.self) { index in
                                Circle()
                                    .fill(index < currentSetNumber ? Color.spotterPrimary : Color.spotterBorder)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, Spacing.xxs)
                    }
                }

                SpotterDivider()

                // Weight Input
                SpotterStepper(
                    value: $weight,
                    step: 5,
                    range: 0...1000,
                    label: "Weight",
                    unit: "lbs"
                )

                SpotterDivider()

                // Reps Input
                repsSection

                SpotterDivider()

                // RPE Selector
                RPESelector(selectedRPE: $selectedRPE)
            }
        }
    }

    private var repsSection: some View {
        HStack(spacing: Spacing.lg) {
            StepperButton(icon: "minus") {
                if reps > 1 {
                    reps -= 1
                    HapticManager.selection()
                }
            }
            .disabled(reps <= 1)

            VStack(spacing: Spacing.xxs) {
                Text("\(reps)")
                    .font(.spotterLargeNumber)
                    .foregroundStyle(Color.spotterText)
                    .contentTransition(.numericText())
                    .animation(SpotterAnimation.quick, value: reps)

                Text("REPS")
                    .font(.spotterCaptionMedium)
                    .foregroundStyle(Color.spotterTextMuted)
                    .tracking(1)
            }
            .frame(minWidth: 120)

            StepperButton(icon: "plus") {
                reps += 1
                HapticManager.selection()
            }
        }
    }

    private var completedSetsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Completed", subtitle: "\(setsForCurrentExercise.count) sets")

            SpotterCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(setsForCurrentExercise.enumerated()), id: \.element.id) { index, set in
                        HStack {
                            // Set number with checkmark
                            ZStack {
                                Circle()
                                    .fill(Color.spotterSuccess)
                                    .frame(width: 28, height: 28)

                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            Text("Set \(index + 1)")
                                .font(.spotterBody)
                                .foregroundStyle(Color.spotterTextSecondary)

                            Spacer()

                            Text("\(set.displayWeight) × \(set.reps)")
                                .font(.spotterBodyMedium)
                                .foregroundStyle(Color.spotterText)

                            if let rpe = set.rpe {
                                Text("@\(rpe)")
                                    .font(.spotterCaption)
                                    .foregroundStyle(rpeColor(for: rpe))
                                    .padding(.horizontal, Spacing.xs)
                                    .padding(.vertical, 2)
                                    .background(rpeColor(for: rpe).opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)

                        if index < setsForCurrentExercise.count - 1 {
                            SpotterDivider()
                                .padding(.leading, 56)
                        }
                    }
                }
            }
        }
    }

    private var quickSessionControls: some View {
        HStack(spacing: Spacing.md) {
            if currentExerciseIndex > 0 {
                Button {
                    withAnimation(SpotterAnimation.standard) {
                        currentExerciseIndex -= 1
                        selectedRPE = nil
                    }
                    HapticManager.selection()
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .font(.spotterBodyMedium)
                    .foregroundStyle(Color.spotterTextSecondary)
                }
            }

            Spacer()

            if currentExerciseIndex < quickSessionExercises.count - 1 {
                Button {
                    withAnimation(SpotterAnimation.standard) {
                        currentExerciseIndex += 1
                        selectedRPE = nil
                    }
                    HapticManager.selection()
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(.spotterBodyMedium)
                    .foregroundStyle(Color.spotterTextSecondary)
                }
            } else {
                Button {
                    showingExercisePicker = true
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "plus")
                        Text("Add Exercise")
                    }
                    .font(.spotterBodyMedium)
                    .foregroundStyle(Color.spotterPrimary)
                }
            }
        }
    }

    private var addExercisePrompt: some View {
        EmptyStateView(
            icon: "dumbbell.fill",
            title: "Ready to lift?",
            message: "Add your first exercise to start logging sets",
            actionTitle: "Add Exercise"
        ) {
            showingExercisePicker = true
        }
    }

    private var allCompleteView: some View {
        VStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.spotterSuccess.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.spotterSuccess)
            }

            VStack(spacing: Spacing.xs) {
                Text("Workout Complete!")
                    .font(.spotterTitle)
                    .foregroundStyle(Color.spotterText)

                Text("Tap Finish to save your session")
                    .font(.spotterBody)
                    .foregroundStyle(Color.spotterTextSecondary)
            }
        }
        .padding(Spacing.xxl)
    }

    private var logSetButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.spotterBackground.opacity(0), Color.spotterBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)

            SpotterButton("Log Set", icon: "checkmark", style: .primary) {
                logSet()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.md)
            .background(Color.spotterBackground)
        }
    }

    // MARK: - Actions

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds = Int(Date().timeIntervalSince(startTime))
        }
    }

    private func formatElapsedTime() -> String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
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

        let setEntry = SetEntry(
            exercise: exercise,
            session: session,
            weight: weight,
            reps: reps,
            rpe: selectedRPE,
            orderIndex: session.sets.count
        )

        withAnimation(SpotterAnimation.bounce) {
            session.sets.append(setEntry)
        }
        HapticManager.logSet()

        if !isQuickSession {
            if currentSetNumber >= targetSets {
                currentSetNumber = 1
                withAnimation(SpotterAnimation.standard) {
                    currentExerciseIndex += 1
                }
                selectedRPE = nil

                if currentExerciseIndex >= plannedExercises.count {
                    HapticManager.completeExercise()
                }
            } else {
                currentSetNumber += 1
            }
        } else {
            selectedRPE = nil
        }
    }

    private func addQuickExercise(_ exercise: Exercise) {
        quickSessionExercises.append(exercise)
        withAnimation(SpotterAnimation.standard) {
            currentExerciseIndex = quickSessionExercises.count - 1
        }
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

    private func rpeColor(for value: Int) -> Color {
        switch value {
        case 6: return .spotterRPE6
        case 7: return .spotterRPE7
        case 8: return .spotterRPE8
        case 9: return .spotterRPE9
        case 10: return .spotterRPE10
        default: return .spotterTextSecondary
        }
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
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                List {
                    ForEach(groupedExercises, id: \.0) { modality, exercises in
                        Section {
                            ForEach(exercises) { exercise in
                                Button {
                                    onSelect(exercise)
                                    dismiss()
                                } label: {
                                    HStack(spacing: Spacing.sm) {
                                        Image(systemName: exercise.modality.icon)
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.spotterTextMuted)
                                            .frame(width: 32)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(exercise.name)
                                                .font(.spotterBodyMedium)
                                                .foregroundStyle(Color.spotterText)

                                            if !exercise.muscleGroups.isEmpty {
                                                Text(exercise.muscleGroups.joined(separator: ", "))
                                                    .font(.spotterCaption)
                                                    .foregroundStyle(Color.spotterTextMuted)
                                            }
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(Color.spotterTextMuted)
                                    }
                                    .padding(.vertical, Spacing.xxs)
                                }
                                .listRowBackground(Color.spotterSurfaceElevated)
                            }
                        } header: {
                            Text(modality.displayName)
                                .font(.spotterCaptionMedium)
                                .foregroundStyle(Color.spotterTextSecondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Add Exercise")
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
