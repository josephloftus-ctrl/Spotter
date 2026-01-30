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
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom segmented control
                    viewToggle
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)

                    if showingCalendar {
                        CalendarView(sessions: sessions, selectedSession: $selectedSession)
                    } else {
                        sessionList
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("HISTORY")
                        .font(.system(size: 13, weight: .bold, design: .default))
                        .tracking(3)
                        .foregroundStyle(Color.spotterTextMuted)
                }
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
        }
    }

    private var viewToggle: some View {
        GlassEffectContainer(spacing: 4) {
            HStack(spacing: 4) {
                toggleButton(title: "Calendar", icon: "calendar", isSelected: showingCalendar) {
                    withAnimation(SpotterAnimation.quick) {
                        showingCalendar = true
                    }
                }

                toggleButton(title: "List", icon: "list.bullet", isSelected: !showingCalendar) {
                    withAnimation(SpotterAnimation.quick) {
                        showingCalendar = false
                    }
                }
            }
            .padding(4)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: CornerRadius.sm))
        }
    }

    private func toggleButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.spotterCaptionMedium)
            }
            .foregroundStyle(isSelected ? Color.spotterText : Color.spotterTextMuted)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .glassEffect(
                isSelected ? .regular.tint(.spotterPrimary.opacity(0.3)).interactive() : .identity,
                in: RoundedRectangle(cornerRadius: CornerRadius.xs)
            )
        }
        .frame(maxWidth: .infinity)
    }

    private var sessionList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(sessions) { session in
                    SessionRowView(session: session)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedSession = session
                            HapticManager.selection()
                        }
                }
            }
            .padding(Spacing.md)
        }
    }
}

struct SessionRowView: View {
    let session: Session

    var body: some View {
        SpotterCard {
            HStack(spacing: Spacing.md) {
                // Date indicator
                VStack(spacing: 2) {
                    Text(dayOfMonth)
                        .font(.spotterMediumNumber)
                        .foregroundStyle(Color.spotterText)
                    Text(monthAbbrev)
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)
                        .textCase(.uppercase)
                }
                .frame(width: 50)

                SpotterDivider()
                    .frame(height: 40)

                // Session info
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    if let planDayName = session.planDayName {
                        Text(planDayName)
                            .font(.spotterBodyMedium)
                            .foregroundStyle(Color.spotterText)
                    } else {
                        Text("Quick Session")
                            .font(.spotterBodyMedium)
                            .foregroundStyle(Color.spotterText)
                    }

                    HStack(spacing: Spacing.sm) {
                        if let duration = session.duration {
                            Label(DateFormatters.formatDuration(duration), systemImage: "clock")
                        }

                        Label("\(session.sets.count) sets", systemImage: "square.stack")
                    }
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextMuted)
                }

                Spacer()

                // Feel indicator
                if let rpe = session.sessionRPE {
                    feelIndicator(rpe: rpe)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.spotterTextMuted)
            }
        }
    }

    private var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: session.date)
    }

    private var monthAbbrev: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: session.date)
    }

    private func feelIndicator(rpe: Int) -> some View {
        let color: Color = {
            switch rpe {
            case 1: return .spotterRPE10
            case 2: return .spotterRPE9
            case 3: return .spotterRPE8
            case 4: return .spotterRPE7
            case 5: return .spotterSuccess
            default: return .spotterTextMuted
            }
        }()

        return Circle()
            .frame(width: 12, height: 12)
            .glassEffect(.regular.tint(color), in: Circle())
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
