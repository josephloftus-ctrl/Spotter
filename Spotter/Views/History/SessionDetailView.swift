import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session

    @State private var showContent = false

    private var exerciseGroups: [(String, [SetEntry])] {
        let grouped = Dictionary(grouping: session.sets) { $0.exercise?.name ?? "Unknown" }
        return grouped.sorted {
            ($0.value.first?.orderIndex ?? 0) < ($1.value.first?.orderIndex ?? 0)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // Session Header
                        sessionHeader
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)

                        // Exercises
                        ForEach(Array(exerciseGroups.enumerated()), id: \.element.0) { index, group in
                            let (exerciseName, sets) = group
                            exerciseSection(name: exerciseName, sets: sets)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(SpotterAnimation.standard.delay(Double(index) * 0.05 + 0.1), value: showContent)
                        }

                        // Pain Tags
                        if !session.painTags.isEmpty {
                            painTagsSection
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                        }

                        // Notes
                        if let notes = session.notes, !notes.isEmpty {
                            notesSection(notes)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                        }
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, Spacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(DateFormatters.formatRelativeDate(session.date))
                        .font(.spotterHeadline)
                        .foregroundStyle(Color.spotterText)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.spotterTextSecondary)
                    }
                }
            }
            .onAppear {
                withAnimation(SpotterAnimation.standard) {
                    showContent = true
                }
            }
        }
    }

    private var sessionHeader: some View {
        SpotterCard(accentEdge: .top) {
            VStack(spacing: Spacing.md) {
                if let planDayName = session.planDayName {
                    Text(planDayName)
                        .font(.spotterTitleSecondary)
                        .foregroundStyle(Color.spotterText)
                }

                // Stats row
                HStack(spacing: 0) {
                    Spacer()
                    headerStat(
                        value: session.duration.map { DateFormatters.formatDuration($0) } ?? "--",
                        label: "Duration",
                        icon: "clock.fill"
                    )
                    Spacer()
                    SpotterDivider()
                        .frame(height: 40)
                    Spacer()
                    headerStat(
                        value: "\(session.sets.count)",
                        label: "Sets",
                        icon: "square.stack.fill"
                    )
                    Spacer()
                    SpotterDivider()
                        .frame(height: 40)
                    Spacer()
                    headerStat(
                        value: formatVolume(session.totalVolume),
                        label: "Volume",
                        icon: "scalemass.fill"
                    )
                    Spacer()
                }

                if let rpe = session.sessionRPE {
                    SpotterDivider()

                    HStack(spacing: Spacing.sm) {
                        Text("Session Feel")
                            .font(.spotterCaption)
                            .foregroundStyle(Color.spotterTextMuted)

                        Spacer()

                        HStack(spacing: Spacing.xxs) {
                            ForEach(1...5, id: \.self) { index in
                                Circle()
                                    .fill(index <= rpe ? feelColor(for: rpe) : Color.spotterBorder)
                                    .frame(width: 10, height: 10)
                            }
                        }

                        Text(feelLabel(for: rpe))
                            .font(.spotterCaptionMedium)
                            .foregroundStyle(feelColor(for: rpe))
                    }
                }
            }
        }
    }

    private func headerStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: Spacing.xxs) {
            Text(value)
                .font(.spotterHeadline)
                .foregroundStyle(Color.spotterText)

            HStack(spacing: Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(.spotterCaption)
            }
            .foregroundStyle(Color.spotterTextMuted)
        }
    }

    private func exerciseSection(name: String, sets: [SetEntry]) -> some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text(name)
                        .font(.spotterHeadline)
                        .foregroundStyle(Color.spotterText)

                    Spacer()

                    if let bestSet = sets.max(by: { OneRepMaxCalculator.estimate(from: $0) < OneRepMaxCalculator.estimate(from: $1) }) {
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("e1RM")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.spotterTextMuted)
                            Text(String(format: "%.0f", OneRepMaxCalculator.estimate(from: bestSet)))
                                .font(.spotterBodyMedium)
                                .foregroundStyle(Color.spotterPrimary)
                        }
                    }
                }

                VStack(spacing: 0) {
                    ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.spotterSuccess)
                                    .frame(width: 24, height: 24)

                                Text("\(index + 1)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            Spacer()

                            Text("\(set.displayWeight)")
                                .font(.spotterBodyMedium)
                                .foregroundStyle(Color.spotterText)

                            Text("×")
                                .font(.spotterBody)
                                .foregroundStyle(Color.spotterTextMuted)

                            Text("\(set.reps)")
                                .font(.spotterBodyMedium)
                                .foregroundStyle(Color.spotterText)

                            if let rpe = set.rpe {
                                Text("@\(rpe)")
                                    .font(.spotterCaption)
                                    .foregroundStyle(rpeColor(for: rpe))
                                    .padding(.horizontal, Spacing.xs)
                                    .padding(.vertical, 2)
                                    .background(rpeColor(for: rpe).opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, Spacing.sm)

                        if index < sets.count - 1 {
                            SpotterDivider()
                                .padding(.leading, 32)
                        }
                    }
                }
            }
        }
    }

    private var painTagsSection: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionHeader("Discomfort Noted")

                HStack(spacing: Spacing.sm) {
                    ForEach(session.painTags, id: \.self) { tag in
                        Text(tag)
                            .font(.spotterCaptionMedium)
                            .foregroundStyle(Color.spotterWarning)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.spotterWarning.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func notesSection(_ notes: String) -> some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionHeader("Notes")

                Text(notes)
                    .font(.spotterBody)
                    .foregroundStyle(Color.spotterTextSecondary)
            }
        }
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }

    private func feelColor(for rpe: Int) -> Color {
        switch rpe {
        case 1: return .spotterRPE10
        case 2: return .spotterRPE9
        case 3: return .spotterRPE8
        case 4: return .spotterRPE7
        case 5: return .spotterSuccess
        default: return .spotterTextMuted
        }
    }

    private func feelLabel(for rpe: Int) -> String {
        switch rpe {
        case 1: return "Rough"
        case 2: return "Hard"
        case 3: return "Okay"
        case 4: return "Good"
        case 5: return "Great"
        default: return ""
        }
    }

    private func rpeColor(for value: Int) -> Color {
        switch value {
        case 6: return .spotterRPE6
        case 7: return .spotterRPE7
        case 8: return .spotterRPE8
        case 9: return .spotterRPE9
        case 10: return .spotterRPE10
        default: return .spotterTextSecondary
        }
    }
}

#Preview {
    let session = Session(
        planDayName: "Day A - Squat Focus",
        duration: 3600,
        sessionRPE: 4,
        notes: "Felt strong today. Good sleep last night.",
        painTags: ["Shoulders"]
    )

    return SessionDetailView(session: session)
}
