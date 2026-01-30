import SwiftUI

struct CalendarView: View {
    let sessions: [Session]
    @Binding var selectedSession: Session?

    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    private var sessionDates: Set<DateComponents> {
        Set(sessions.map { calendar.dateComponents([.year, .month, .day], from: $0.date) })
    }

    private var monthStart: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
    }

    private var daysInMonth: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: monthStart)!
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Month Navigation
            monthNavigation

            // Day Headers
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.spotterCaptionMedium)
                        .foregroundStyle(Color.spotterTextMuted)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: Spacing.xs) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 48)
                    }
                }
            }

            Spacer()
        }
        .padding(Spacing.md)
    }

    private var monthNavigation: some View {
        HStack {
            Button {
                withAnimation(SpotterAnimation.quick) {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                }
                HapticManager.selection()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.spotterPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.spotterSurface)
                    .clipShape(Circle())
            }

            Spacer()

            Text(DateFormatters.monthYear.string(from: displayedMonth))
                .font(.spotterHeadline)
                .foregroundStyle(Color.spotterText)

            Spacer()

            Button {
                withAnimation(SpotterAnimation.quick) {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                }
                HapticManager.selection()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.spotterPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.spotterSurface)
                    .clipShape(Circle())
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let hasSession = sessionDates.contains(components)
        let isToday = calendar.isDateInToday(date)
        let sessionForDate = sessions.first { calendar.isDate($0.date, inSameDayAs: date) }
        let isFuture = date > Date()

        return Button {
            if let session = sessionForDate {
                selectedSession = session
                HapticManager.selection()
            }
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.spotterBodyMedium)
                    .foregroundStyle(dayTextColor(isToday: isToday, hasSession: hasSession, isFuture: isFuture))

                if hasSession {
                    Circle()
                        .fill(isToday ? .white : Color.spotterSuccess)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                ZStack {
                    if isToday {
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(LinearGradient.spotterPrimaryGradient)
                    } else if hasSession {
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(Color.spotterSuccess.opacity(0.1))
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .strokeBorder(
                        hasSession && !isToday ? Color.spotterSuccess.opacity(0.3) : Color.clear,
                        lineWidth: BorderWidth.thin
                    )
            )
        }
        .disabled(!hasSession)
    }

    private func dayTextColor(isToday: Bool, hasSession: Bool, isFuture: Bool) -> Color {
        if isToday {
            return .white
        } else if isFuture {
            return Color.spotterTextMuted
        } else if hasSession {
            return Color.spotterText
        } else {
            return Color.spotterTextSecondary
        }
    }
}

#Preview {
    CalendarView(sessions: [], selectedSession: .constant(nil))
        .background(Color.spotterBackground)
}
