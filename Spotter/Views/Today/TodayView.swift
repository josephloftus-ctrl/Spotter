import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
    @Query(filter: #Predicate<TrainingPlan> { $0.isActive }) private var activePlans: [TrainingPlan]

    @State private var showingActiveSession = false

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

        // Simple rotation: find last completed day and return next
        if let lastSession = lastSession,
           let lastDayName = lastSession.planDayName,
           let lastIndex = sortedDays.firstIndex(where: { $0.name == lastDayName }) {
            let nextIndex = (lastIndex + 1) % sortedDays.count
            return sortedDays[nextIndex]
        }

        return sortedDays.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Date Header
                    dateHeader

                    // Plan Day Indicator
                    if let planDay = nextPlanDay {
                        planDayIndicator(planDay)
                    }

                    Divider()
                        .foregroundStyle(Color.spotterBorder)

                    // Last Session
                    if let session = lastSession {
                        LastSessionCard(session: session)
                    }

                    // Today's Session Preview
                    if let planDay = nextPlanDay {
                        TodaySessionCard(planDay: planDay)
                    }

                    Spacer(minLength: Spacing.lg)

                    // Start Session Button
                    startSessionButton
                }
                .padding(Spacing.md)
            }
            .background(Color.spotterBackground)
            .navigationTitle("Today")
            .fullScreenCover(isPresented: $showingActiveSession) {
                ActiveSessionView(planDay: nextPlanDay)
            }
        }
    }

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(DateFormatters.dayOfWeek.string(from: Date()))
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)
            Text(DateFormatters.shortDate.string(from: Date()))
                .font(.spotterTitle)
                .foregroundStyle(Color.spotterText)
        }
        .padding(.top, Spacing.sm)
    }

    private func planDayIndicator(_ planDay: PlanDay) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "figure.strengthtraining.traditional")
                .foregroundStyle(Color.spotterPrimary)
            Text(planDay.name)
                .font(.spotterHeadline)
                .foregroundStyle(Color.spotterText)
        }
    }

    private var startSessionButton: some View {
        Button {
            HapticManager.buttonTap()
            showingActiveSession = true
        } label: {
            Text("Start Session")
                .font(.spotterHeadline)
                .foregroundStyle(Color.spotterPrimary)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .strokeBorder(Color.spotterPrimary, lineWidth: BorderWidth.medium)
                )
        }
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
