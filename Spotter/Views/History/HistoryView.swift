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
            VStack {
                // View Toggle
                Picker("View", selection: $showingCalendar) {
                    Text("Calendar").tag(true)
                    Text("List").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if showingCalendar {
                    CalendarView(sessions: sessions, selectedSession: $selectedSession)
                } else {
                    sessionList
                }
            }
            .navigationTitle("History")
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
        }
    }

    private var sessionList: some View {
        List {
            ForEach(sessions) { session in
                SessionRowView(session: session)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSession = session
                    }
            }
        }
        .listStyle(.plain)
    }
}

struct SessionRowView: View {
    let session: Session

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(DateFormatters.formatRelativeDate(session.date))
                    .font(.spotterHeadline)

                if let planDayName = session.planDayName {
                    Text(planDayName)
                        .font(.spotterCaption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: Spacing.md) {
                if let duration = session.duration {
                    Text(DateFormatters.formatDuration(duration))
                        .font(.spotterCaption)
                        .foregroundStyle(.secondary)
                }

                if let rpe = session.sessionRPE {
                    Text(rpeEmoji(rpe))
                }
            }
        }
        .padding(.vertical, Spacing.sm)
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
