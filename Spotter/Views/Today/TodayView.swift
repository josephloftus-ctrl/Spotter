import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Query(filter: #Predicate<TrainingPlan> { $0.isActive }) private var activePlans: [TrainingPlan]

    @State private var showingActiveSession = false
    @State private var showingQuickSession = false
    @State private var headerScale: CGFloat = 1.0

    private var lastSession: Session? {
        sessions.first { $0.isCompleted }
    }

    private var activePlan: TrainingPlan? {
        activePlans.first
    }

    private var nextPlanDay: PlanDay? {
        guard let plan = activePlan else { return nil }
        let sortedDays = plan.sortedDays
        guard !sortedDays.isEmpty else { return nil }

        if let lastSession = lastSession,
           let lastDayName = lastSession.planDayName,
           let lastIndex = sortedDays.firstIndex(where: { $0.name == lastDayName }) {
            let nextIndex = (lastIndex + 1) % sortedDays.count
            return sortedDays[nextIndex]
        }

        return sortedDays.first
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Late night gains"
        }
    }

    private var weekSessionCount: Int {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return sessions.filter { $0.date >= weekStart && $0.isCompleted }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Hero Header
                    heroHeader
                        .padding(.top, Spacing.md)

                    // Week Progress
                    weekProgressCard

                    // Last Session
                    if let session = lastSession {
                        LastSessionCard(session: session)
                    }

                    // Today's Plan Preview
                    if let planDay = nextPlanDay {
                        TodaySessionCard(planDay: planDay)
                    }

                    Spacer(minLength: Spacing.xl)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, 120) // Space for button
            }
            .background(Color.spotterBackground)
            .safeAreaInset(edge: .bottom) {
                actionButtons
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SPOTTER")
                        .font(.system(size: 13, weight: .bold, design: .default))
                        .tracking(3)
                        .foregroundStyle(Color.spotterTextMuted)
                }
            }
            .fullScreenCover(isPresented: $showingActiveSession) {
                ActiveSessionView(planDay: nextPlanDay)
            }
            .fullScreenCover(isPresented: $showingQuickSession) {
                ActiveSessionView(planDay: nil)
            }
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(greeting)
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)
                .textCase(.uppercase)
                .tracking(1)

            Text(DateFormatters.shortDate.string(from: Date()))
                .font(.spotterTitle)
                .foregroundStyle(Color.spotterText)

            if let planDay = nextPlanDay {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.spotterPrimary)
                        .font(.system(size: 14))
                    Text(planDay.name)
                        .font(.spotterBodyMedium)
                        .foregroundStyle(Color.spotterPrimary)
                }
                .padding(.top, Spacing.xxs)
            }
        }
    }

    private var weekProgressCard: some View {
        SpotterCard(accentEdge: .top) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("This Week")
                            .font(.spotterCaptionMedium)
                            .foregroundStyle(Color.spotterTextSecondary)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                            Text("\(weekSessionCount)")
                                .font(.spotterDisplay)
                                .foregroundStyle(Color.spotterText)

                            Text("sessions")
                                .font(.spotterBody)
                                .foregroundStyle(Color.spotterTextMuted)
                        }
                    }

                    Spacer()

                    // Mini progress ring
                    ProgressRing(
                        progress: min(Double(weekSessionCount) / 5.0, 1.0),
                        lineWidth: 6,
                        size: 52
                    )
                }

                // Week dots
                weekDots
            }
        }
    }

    private var weekDots: some View {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

        return HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { dayOffset in
                let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
                let hasSession = sessions.contains { calendar.isDate($0.date, inSameDayAs: date) && $0.isCompleted }
                let isToday = calendar.isDateInToday(date)
                let isFuture = date > Date()

                VStack(spacing: Spacing.xxs) {
                    Text(dayLabels[dayOffset])
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(isToday ? Color.spotterPrimary : Color.spotterTextMuted)

                    ZStack {
                        Circle()
                            .fill(hasSession ? Color.spotterSuccess : Color.spotterSurface)
                            .frame(width: 26, height: 26)

                        if hasSession {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        } else if isFuture {
                            Circle()
                                .fill(Color.spotterBorder)
                                .frame(width: 5, height: 5)
                        }

                        if isToday && !hasSession {
                            Circle()
                                .strokeBorder(Color.spotterPrimary, lineWidth: 2)
                                .frame(width: 26, height: 26)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: Spacing.sm) {
            // Primary action
            if nextPlanDay != nil {
                SpotterButton("Start Session", icon: "flame.fill", style: .primary) {
                    showingActiveSession = true
                }
            }

            // Secondary: Quick session
            SpotterButton("Quick Session", icon: "bolt.fill", style: .secondary) {
                showingQuickSession = true
            }
        }
        .padding(Spacing.md)
        .background(
            LinearGradient(
                colors: [Color.spotterBackground.opacity(0), Color.spotterBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)
            .offset(y: -40),
            alignment: .top
        )
        .background(Color.spotterBackground)
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
