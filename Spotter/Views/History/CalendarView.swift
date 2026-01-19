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

        // Pad to complete last week
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Month Navigation
            HStack {
                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(DateFormatters.monthYear.string(from: displayedMonth))
                    .font(.spotterHeadline)

                Spacer()

                Button {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // Day Headers
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.spotterCaption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: Spacing.sm) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }

            Spacer()
        }
        .padding()
    }

    private func dayCell(for date: Date) -> some View {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let hasSession = sessionDates.contains(components)
        let isToday = calendar.isDateInToday(date)
        let sessionForDate = sessions.first { calendar.isDate($0.date, inSameDayAs: date) }

        return Button {
            if let session = sessionForDate {
                selectedSession = session
            }
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.spotterBody)
                    .foregroundStyle(isToday ? .white : .primary)

                if hasSession {
                    Circle()
                        .fill(Color.spotterPrimaryFallback)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(isToday ? Color.spotterPrimaryFallback : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
        }
        .disabled(!hasSession)
    }
}

#Preview {
    CalendarView(sessions: [], selectedSession: .constant(nil))
}
