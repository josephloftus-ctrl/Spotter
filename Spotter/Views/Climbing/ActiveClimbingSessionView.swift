import SwiftUI
import SwiftData

struct ActiveClimbingSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var healthKitManager = HealthKitManager.shared
    private let watchManager = WatchConnectivityManager.shared

    let gym: Gym

    @State private var session: Session
    @State private var selectedWall: Wall?
    @State private var selectedGrade: ClimbingGrade?
    @State private var selectedResult: ClimbResult = .send
    @State private var attempts: Int = 1
    @State private var startTime = Date()
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?
    @State private var showingSessionComplete = false

    init(gym: Gym) {
        self.gym = gym
        self._session = State(initialValue: Session(
            sessionType: .climbing,
            gym: gym
        ))
    }

    private var currentGradeSystem: GradeSystem {
        selectedWall?.defaultGradeSystem ?? .vScale
    }

    private var canLogClimb: Bool {
        selectedWall != nil && selectedGrade != nil
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
                            // Wall Selector
                            WallSelector(
                                walls: gym.sortedWalls,
                                selectedWall: $selectedWall
                            )
                            .onChange(of: selectedWall) { _, newWall in
                                // Reset grade when wall changes (different grade system)
                                if let wall = newWall {
                                    let newSystem = wall.defaultGradeSystem
                                    if selectedGrade?.system != newSystem {
                                        selectedGrade = nil
                                    }
                                }
                            }

                            // Climb Entry Card
                            climbEntryCard

                            // Logged Climbs
                            if !session.climbs.isEmpty {
                                loggedClimbsSection
                            }
                        }
                        .padding(Spacing.md)
                        .padding(.bottom, 100)
                    }
                }

                // Fixed bottom action
                VStack {
                    Spacer()
                    logClimbButton
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
                    VStack(spacing: 2) {
                        Text(gym.name)
                            .font(.spotterHeadline)
                            .foregroundStyle(Color.spotterText)
                        Text("Climbing Session")
                            .font(.spotterCaption)
                            .foregroundStyle(Color.spotterTextMuted)
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        finishSession()
                    } label: {
                        Text("Finish")
                            .font(.spotterLabel)
                            .foregroundStyle(session.climbs.isEmpty ? Color.spotterTextMuted : Color.spotterPrimary)
                    }
                    .disabled(session.climbs.isEmpty)
                }
            }
            .sheet(isPresented: $showingSessionComplete) {
                ClimbingSessionCompleteView(session: session) {
                    dismiss()
                }
            }
            .onAppear {
                modelContext.insert(session)
                startTimer()
                healthKitManager.startHeartRateMonitoring()

                // Pre-select first wall
                if selectedWall == nil {
                    selectedWall = gym.sortedWalls.first
                }

                // Notify watch
                watchManager.sendSessionStart(gymName: gym.name)
            }
            .onDisappear {
                timer?.invalidate()
                watchManager.sendSessionEnd()
            }
        }
    }

    private var sessionHeader: some View {
        GlassEffectContainer(spacing: Spacing.lg) {
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

                // Climbs counter
                VStack(alignment: .center, spacing: Spacing.xxs) {
                    Text("Climbs")
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Text("\(session.climbs.count)")
                        .font(.spotterMediumNumber)
                        .foregroundStyle(Color.spotterText)
                        .contentTransition(.numericText())
                        .animation(SpotterAnimation.bounce, value: session.climbs.count)
                }

                // Heart rate (if available)
                if let heartRate = healthKitManager.currentHeartRate {
                    VStack(alignment: .trailing, spacing: Spacing.xxs) {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.red)
                            Text("HR")
                                .font(.spotterCaption)
                                .foregroundStyle(Color.spotterTextMuted)
                                .textCase(.uppercase)
                                .tracking(0.5)
                        }

                        Text(String(format: "%.0f", heartRate))
                            .font(.spotterMediumNumber)
                            .foregroundStyle(Color.spotterText)
                            .contentTransition(.numericText())
                    }
                }
            }
            .padding(Spacing.md)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: CornerRadius.md))
        }
    }

    private var climbEntryCard: some View {
        SpotterCard {
            VStack(spacing: Spacing.lg) {
                // Grade Selector
                GradeSelector(
                    gradeSystem: currentGradeSystem,
                    selectedGrade: $selectedGrade
                )

                SpotterDivider()

                // Result Picker
                ResultPicker(selectedResult: $selectedResult)

                // Attempts (only show for project/fall)
                if selectedResult == .project || selectedResult == .fall {
                    SpotterDivider()
                    attemptsStepper
                }
            }
        }
    }

    private var attemptsStepper: some View {
        HStack(spacing: Spacing.lg) {
            StepperButton(icon: "minus") {
                if attempts > 1 {
                    attempts -= 1
                    HapticManager.selection()
                }
            }
            .disabled(attempts <= 1)

            VStack(spacing: Spacing.xxs) {
                Text("\(attempts)")
                    .font(.spotterLargeNumber)
                    .foregroundStyle(Color.spotterText)
                    .contentTransition(.numericText())
                    .animation(SpotterAnimation.quick, value: attempts)

                Text("ATTEMPTS")
                    .font(.spotterCaptionMedium)
                    .foregroundStyle(Color.spotterTextMuted)
                    .tracking(1)
            }
            .frame(minWidth: 120)

            StepperButton(icon: "plus") {
                if attempts < 99 {
                    attempts += 1
                    HapticManager.selection()
                }
            }
        }
    }

    private var loggedClimbsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(
                "Logged",
                subtitle: "\(session.sendCount) sends, \(session.flashCount) flashes"
            )

            SpotterCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(session.climbs.reversed().enumerated()), id: \.element.id) { index, climb in
                        ClimbRow(climb: climb)

                        if index < session.climbs.count - 1 {
                            SpotterDivider()
                                .padding(.leading, 56)
                        }
                    }
                }
            }
        }
    }

    private var logClimbButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.spotterBackground.opacity(0), Color.spotterBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)

            SpotterButton("Log Climb", icon: "checkmark", style: .primary) {
                logClimb()
            }
            .disabled(!canLogClimb)
            .opacity(canLogClimb ? 1 : 0.5)
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.md)
            .background(Color.spotterBackground)
        }
    }

    // MARK: - Actions

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            elapsedSeconds = Int(Date().timeIntervalSince(startTime))

            // Send watch update every 5 seconds
            if elapsedSeconds % 5 == 0 {
                sendWatchUpdate()
            }
        }
    }

    private func sendWatchUpdate() {
        watchManager.sendSessionUpdate(
            duration: TimeInterval(elapsedSeconds),
            heartRate: healthKitManager.currentHeartRate,
            climbCount: session.climbs.count,
            sendCount: session.sendCount,
            gymName: gym.name
        )
    }

    private func formatElapsedTime() -> String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func logClimb() {
        guard let grade = selectedGrade, let wall = selectedWall else { return }

        let climb = Climb(
            grade: grade,
            result: selectedResult,
            attempts: (selectedResult == .project || selectedResult == .fall) ? attempts : 1,
            session: session,
            wall: wall,
            orderIndex: session.climbs.count
        )

        withAnimation(SpotterAnimation.bounce) {
            session.climbs.append(climb)
        }
        HapticManager.logSet()

        // Send immediate watch update
        sendWatchUpdate()

        // Reset for next climb
        selectedGrade = nil
        attempts = 1
        // Keep the result as is for quick logging of similar climbs
    }

    private func finishSession() {
        session.duration = Date().timeIntervalSince(startTime)

        // Get heart rate stats
        let hrStats = healthKitManager.stopMonitoring()
        session.averageHeartRate = hrStats.average
        session.maxHeartRate = hrStats.max

        showingSessionComplete = true
    }
}

// MARK: - Climb Row

struct ClimbRow: View {
    let climb: Climb

    private var resultColor: Color {
        switch climb.result {
        case .flash: return .spotterWarning
        case .send: return .spotterSuccess
        case .project: return .spotterPrimary
        case .fall: return .spotterTextMuted
        }
    }

    var body: some View {
        HStack {
            // Result icon
            ZStack {
                Circle()
                    .fill(resultColor)
                    .frame(width: 28, height: 28)

                Image(systemName: climb.result.icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(climb.displayGrade)
                    .font(.spotterBodyMedium)
                    .foregroundStyle(Color.spotterText)

                if let wallName = climb.wall?.name {
                    Text(wallName)
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)
                }
            }

            Spacer()

            HStack(spacing: Spacing.sm) {
                Text(climb.result.displayName)
                    .font(.spotterCaptionMedium)
                    .foregroundStyle(resultColor)

                if climb.attempts > 1 {
                    Text("×\(climb.attempts)")
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    let gym = Gym(name: "Rockville", city: "Ewing", state: "NJ", isDefault: true)

    return ActiveClimbingSessionView(gym: gym)
        .modelContainer(for: [
            Session.self,
            Climb.self,
            Gym.self,
            Wall.self
        ], inMemory: true)
}
