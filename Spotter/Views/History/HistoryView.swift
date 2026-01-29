import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Session> { $0.completedAt != nil },
        sort: [SortDescriptor(\Session.date, order: .reverse)]
    ) private var sessions: [Session]

    @State private var selectedSession: Session?
    @State private var showingCalendar = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View Toggle
                Picker("View", selection: $showingCalendar) {
                    Text("Calendar").tag(true)
                    Text("List").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)

                Divider()
                    .foregroundStyle(Color.spotterBorder)

                if showingCalendar {
                    CalendarView(sessions: sessions, selectedSession: $selectedSession)
                } else {
                    sessionList
                }
            }
            .background(Color.spotterBackground)
            .navigationTitle("History")
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
        }
    }

    private var sessionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sessions) { session in
                    SessionRowView(session: session)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedSession = session
                        }

                    Divider()
                        .foregroundStyle(Color.spotterBorder)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

struct SessionRowView: View {
    let session: Session

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(DateFormatters.formatRelativeDate(session.date))
                    .font(.spotterHeadline)
                    .foregroundStyle(Color.spotterText)

                if let planDayName = session.planDayName {
                    Text(planDayName)
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextSecondary)
                }
            }

            Spacer()

            HStack(spacing: Spacing.md) {
                if let duration = session.duration {
                    Text(DateFormatters.formatDuration(duration))
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextSecondary)
                }

                if let rpe = session.sessionRPE {
                    Text(rpeEmoji(rpe))
                }
            }
        }
        .padding(.vertical, Spacing.md)
    }

    private func rpeEmoji(_ rpe: Int) -> String {
        let emojis = ["😫", "😓", "😐", "💪", "🔥"]
        guard rpe >= 1 && rpe <= 5 else { return "" }
        return emojis[rpe - 1]
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
