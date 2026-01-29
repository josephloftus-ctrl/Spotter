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
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Consistency Card
                    consistencyCard

                    Divider()
                        .foregroundStyle(Color.spotterBorder)

                    // Exercise Picker
                    if !exerciseOptions.isEmpty {
                        exercisePicker
                    }

                    // Progress Chart
                    if let exercise = selectedExercise {
                        progressChart(for: exercise)
                    }

                    // Weekly Volume
                    weeklyVolumeCard
                }
                .padding(Spacing.md)
            }
            .background(Color.spotterBackground)
            .navigationTitle("Trends")
            .onAppear {
                if selectedExercise == nil {
                    selectedExercise = exerciseOptions.first
                }
            }
        }
    }

    private var consistencyCard: some View {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let sessionsThisWeek = sessions.filter { $0.date >= weekStart }

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("This Week")
                .font(.spotterLabel)
                .foregroundStyle(Color.spotterTextSecondary)

            HStack(alignment: .bottom, spacing: Spacing.sm) {
                Text("\(sessionsThisWeek.count)")
                    .font(.spotterLargeNumber)
                    .foregroundStyle(Color.spotterText)

                Text("sessions")
                    .font(.spotterBody)
                    .foregroundStyle(Color.spotterTextSecondary)
                    .padding(.bottom, 8)
            }

            // Week dots
            HStack(spacing: Spacing.sm) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
                    let hasSession = sessions.contains { calendar.isDate($0.date, inSameDayAs: date) }
                    let isToday = calendar.isDateInToday(date)

                    Circle()
                        .fill(hasSession ? Color.spotterSuccess : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay {
                            Circle()
                                .strokeBorder(isToday ? Color.spotterPrimary : Color.spotterBorder, lineWidth: isToday ? BorderWidth.medium : BorderWidth.thin)
                        }
                }
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spotterSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var exercisePicker: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Track Progress")
                .font(.spotterLabel)
                .foregroundStyle(Color.spotterTextSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(exerciseOptions) { exercise in
                        Button {
                            selectedExercise = exercise
                            HapticManager.selection()
                        } label: {
                            Text(exercise.name)
                                .font(.spotterBody)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .fill(selectedExercise?.id == exercise.id ? Color.spotterPrimary : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .strokeBorder(selectedExercise?.id == exercise.id ? Color.clear : Color.spotterBorder, lineWidth: BorderWidth.thin)
                                )
                                .foregroundStyle(selectedExercise?.id == exercise.id ? .white : Color.spotterText)
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

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Estimated 1RM")
                .font(.spotterHeadline)
                .foregroundStyle(Color.spotterText)

            if dataPoints.isEmpty {
                Text("No data yet for \(exercise.name)")
                    .font(.spotterCaption)
                    .foregroundStyle(Color.spotterTextSecondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(dataPoints, id: \.date) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("e1RM", point.e1rm)
                        )
                        .foregroundStyle(Color.spotterPrimary)

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("e1RM", point.e1rm)
                        )
                        .foregroundStyle(Color.spotterPrimary)
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.spotterSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var weeklyVolumeCard: some View {
        let calendar = Calendar.current
        let last4Weeks = (0..<4).map { weekOffset -> (weekStart: Date, volume: Double) in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!

            let weekSessions = sessions.filter { $0.date >= weekStart && $0.date < weekEnd }
            let volume = weekSessions.reduce(0.0) { $0 + $1.totalVolume }

            return (weekStart, volume)
        }.reversed()

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Weekly Volume")
                .font(.spotterHeadline)
                .foregroundStyle(Color.spotterText)

            Chart {
                ForEach(Array(last4Weeks), id: \.weekStart) { data in
                    BarMark(
                        x: .value("Week", data.weekStart, unit: .weekOfYear),
                        y: .value("Volume", data.volume)
                    )
                    .foregroundStyle(Color.spotterPrimary)
                }
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                    AxisValueLabel(format: .dateTime.week())
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.spotterSurface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
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
