import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Query(
        filter: #Predicate<Session> { $0.completedAt != nil },
        sort: [SortDescriptor(\Session.date, order: .reverse)]
    ) private var sessions: [Session]

    @Query private var exercises: [Exercise]

    @State private var selectedExercise: Exercise?
    @State private var showContent = false

    private var mainLifts: [Exercise] {
        let mainLiftNames = ["Back Squat", "Bench Press", "Deadlift", "Overhead Press", "Barbell Row"]
        return exercises.filter { mainLiftNames.contains($0.name) }
    }

    private var exerciseOptions: [Exercise] {
        if mainLifts.isEmpty {
            return Array(exercises.prefix(5))
        }
        return mainLifts
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Consistency Card - Hero
                        consistencyCard
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)

                        // Exercise Picker
                        if !exerciseOptions.isEmpty {
                            exercisePicker
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(SpotterAnimation.standard.delay(0.1), value: showContent)
                        }

                        // Progress Chart
                        if let exercise = selectedExercise {
                            progressChart(for: exercise)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(SpotterAnimation.standard.delay(0.15), value: showContent)
                        }

                        // Weekly Volume
                        weeklyVolumeCard
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(SpotterAnimation.standard.delay(0.2), value: showContent)
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, Spacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TRENDS")
                        .font(.system(size: 13, weight: .bold, design: .default))
                        .tracking(3)
                        .foregroundStyle(Color.spotterTextMuted)
                }
            }
            .onAppear {
                if selectedExercise == nil {
                    selectedExercise = exerciseOptions.first
                }
                withAnimation(SpotterAnimation.standard) {
                    showContent = true
                }
            }
        }
    }

    private var consistencyCard: some View {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let sessionsThisWeek = sessions.filter { $0.date >= weekStart }
        let streak = calculateStreak()

        return SpotterCard(accentEdge: .top) {
            VStack(spacing: Spacing.lg) {
                HStack(alignment: .top) {
                    // Sessions this week
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("This Week")
                            .font(.spotterCaptionMedium)
                            .foregroundStyle(Color.spotterTextSecondary)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                            Text("\(sessionsThisWeek.count)")
                                .font(.spotterDisplay)
                                .foregroundStyle(Color.spotterText)

                            Text("sessions")
                                .font(.spotterBody)
                                .foregroundStyle(Color.spotterTextMuted)
                        }
                    }

                    Spacer()

                    // Streak badge
                    if streak > 0 {
                        VStack(spacing: Spacing.xxs) {
                            HStack(spacing: Spacing.xxs) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(Color.spotterPrimary)
                                Text("\(streak)")
                                    .font(.spotterHeadline)
                                    .foregroundStyle(Color.spotterText)
                            }
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.spotterPrimaryMuted)
                            .clipShape(Capsule())

                            Text("week streak")
                                .font(.spotterCaption)
                                .foregroundStyle(Color.spotterTextMuted)
                        }
                    }
                }

                // Week visualization
                weekVisualization(weekStart: weekStart, sessions: sessions)
            }
        }
    }

    private func weekVisualization(weekStart: Date, sessions: [Session]) -> some View {
        let calendar = Calendar.current
        let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        return HStack(spacing: Spacing.xs) {
            ForEach(0..<7, id: \.self) { dayOffset in
                let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
                let hasSession = sessions.contains { calendar.isDate($0.date, inSameDayAs: date) }
                let isToday = calendar.isDateInToday(date)
                let isFuture = date > Date()

                VStack(spacing: Spacing.xs) {
                    Text(dayLabels[dayOffset])
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(isToday ? Color.spotterPrimary : Color.spotterTextMuted)

                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.xs)
                            .fill(hasSession ? Color.spotterSuccess : Color.spotterSurface)
                            .frame(height: 32)

                        if hasSession {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        } else if !isFuture {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.spotterBorder)
                                .frame(width: 8, height: 2)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.xs)
                            .strokeBorder(
                                isToday ? Color.spotterPrimary : Color.clear,
                                lineWidth: 2
                            )
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        // Go back week by week
        for _ in 0..<52 {
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: checkDate))!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

            let hasSession = sessions.contains { $0.date >= weekStart && $0.date < weekEnd }

            if hasSession {
                streak += 1
                checkDate = calendar.date(byAdding: .weekOfYear, value: -1, to: checkDate)!
            } else {
                break
            }
        }

        return streak
    }

    private var exercisePicker: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Track Progress", subtitle: "Select an exercise")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(exerciseOptions) { exercise in
                        SpotterChip(
                            label: exercise.name,
                            isSelected: selectedExercise?.id == exercise.id
                        ) {
                            withAnimation(SpotterAnimation.standard) {
                                selectedExercise = exercise
                            }
                        }
                    }
                }
            }
        }
    }

    private func progressChart(for exercise: Exercise) -> some View {
        let sets = exercise.sets.sorted { $0.timestamp < $1.timestamp }
        let dataPoints = sets.map {
            (date: $0.timestamp, e1rm: OneRepMaxCalculator.estimate(from: $0))
        }

        return SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Estimated 1RM")
                            .font(.spotterHeadline)
                            .foregroundStyle(Color.spotterText)

                        Text(exercise.name)
                            .font(.spotterCaption)
                            .foregroundStyle(Color.spotterTextMuted)
                    }

                    Spacer()

                    if let latest = dataPoints.last {
                        VStack(alignment: .trailing, spacing: Spacing.xxs) {
                            Text("\(Int(latest.e1rm))")
                                .font(.spotterMediumNumber)
                                .foregroundStyle(Color.spotterPrimary)

                            Text("lbs")
                                .font(.spotterCaption)
                                .foregroundStyle(Color.spotterTextMuted)
                        }
                    }
                }

                if dataPoints.isEmpty {
                    emptyChartState(for: exercise)
                } else {
                    Chart {
                        ForEach(dataPoints, id: \.date) { point in
                            AreaMark(
                                x: .value("Date", point.date),
                                y: .value("e1RM", point.e1rm)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.spotterPrimary.opacity(0.3), Color.spotterPrimary.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("e1RM", point.e1rm)
                            )
                            .foregroundStyle(Color.spotterPrimary)
                            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("e1RM", point.e1rm)
                            )
                            .foregroundStyle(Color.spotterPrimary)
                            .symbolSize(30)
                        }
                    }
                    .frame(height: 180)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                                .foregroundStyle(Color.spotterBorder)
                            AxisValueLabel()
                                .foregroundStyle(Color.spotterTextMuted)
                        }
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisGridLine()
                                .foregroundStyle(Color.spotterBorder)
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                .foregroundStyle(Color.spotterTextMuted)
                        }
                    }
                }
            }
        }
    }

    private func emptyChartState(for exercise: Exercise) -> some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 32))
                .foregroundStyle(Color.spotterTextMuted)

            Text("No data yet")
                .font(.spotterBodyMedium)
                .foregroundStyle(Color.spotterTextSecondary)

            Text("Log some \(exercise.name) sets to see your progress")
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextMuted)
                .multilineTextAlignment(.center)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }

    private var weeklyVolumeCard: some View {
        let calendar = Calendar.current
        let last4Weeks = (0..<4).map { weekOffset -> (weekStart: Date, volume: Double, label: String) in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

            let weekSessions = sessions.filter { $0.date >= weekStart && $0.date < weekEnd }
            let volume = weekSessions.reduce(0.0) { $0 + $1.totalVolume }

            let label = weekOffset == 0 ? "This" : weekOffset == 1 ? "Last" : "\(weekOffset)w ago"

            return (weekStart, volume, label)
        }.reversed()

        let maxVolume = last4Weeks.map(\.volume).max() ?? 1

        return SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader("Weekly Volume", subtitle: "Last 4 weeks")

                HStack(alignment: .bottom, spacing: Spacing.md) {
                    ForEach(Array(last4Weeks), id: \.weekStart) { data in
                        VStack(spacing: Spacing.xs) {
                            // Value label
                            Text(formatVolumeShort(data.volume))
                                .font(.spotterCaptionMedium)
                                .foregroundStyle(Color.spotterTextSecondary)

                            // Bar
                            RoundedRectangle(cornerRadius: CornerRadius.xs)
                                .fill(
                                    data.label == "This"
                                        ? LinearGradient.spotterPrimaryGradient
                                        : LinearGradient(colors: [Color.spotterBorderLight], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(height: max(8, CGFloat(data.volume / maxVolume) * 100))

                            // Week label
                            Text(data.label)
                                .font(.spotterCaption)
                                .foregroundStyle(Color.spotterTextMuted)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 140)
            }
        }
    }

    private func formatVolumeShort(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.0fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }
}

#Preview {
    TrendsView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
