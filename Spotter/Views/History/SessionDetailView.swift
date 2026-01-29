import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session

    private var exerciseGroups: [(String, [SetEntry])] {
        let grouped = Dictionary(grouping: session.sets) { $0.exercise?.name ?? "Unknown" }
        return grouped.sorted {
            ($0.value.first?.orderIndex ?? 0) < ($1.value.first?.orderIndex ?? 0)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Session Header
                    sessionHeader

                    Divider()
                        .foregroundStyle(Color.spotterBorder)

                    // Exercises
                    ForEach(exerciseGroups, id: \.0) { exerciseName, sets in
                        exerciseSection(name: exerciseName, sets: sets)
                    }

                    // Pain Tags
                    if !session.painTags.isEmpty {
                        painTagsSection
                    }

                    // Notes
                    if let notes = session.notes, !notes.isEmpty {
                        notesSection(notes)
                    }
                }
                .padding(Spacing.md)
            }
            .background(Color.spotterBackground)
            .navigationTitle(DateFormatters.formatRelativeDate(session.date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.spotterPrimary)
                }
            }
        }
    }

    private var sessionHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if let planDayName = session.planDayName {
                Text(planDayName)
                    .font(.spotterHeadline)
                    .foregroundStyle(Color.spotterText)
            }

            HStack(spacing: Spacing.lg) {
                if let duration = session.duration {
                    Label(DateFormatters.formatDuration(duration), systemImage: "clock")
                }

                Label("\(session.sets.count) sets", systemImage: "number")

                if let rpe = session.sessionRPE {
                    Label(rpeEmoji(rpe), systemImage: "heart")
                }
            }
            .font(.spotterCaption)
            .foregroundStyle(Color.spotterTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func exerciseSection(name: String, sets: [SetEntry]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(name)
                .font(.spotterHeadline)
                .foregroundStyle(Color.spotterText)

            VStack(spacing: 0) {
                ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                    HStack {
                        Text("Set \(index + 1)")
                            .font(.spotterBody)
                            .foregroundStyle(Color.spotterTextSecondary)
                        Spacer()
                        Text("\(set.displayWeight) × \(set.reps)")
                            .font(.spotterBody)
                            .foregroundStyle(Color.spotterText)
                        if let rpe = set.rpe {
                            Text("@\(rpe)")
                                .font(.spotterCaption)
                                .foregroundStyle(Color.spotterTextSecondary)
                        }
                    }
                    .padding(.vertical, Spacing.sm)

                    if index < sets.count - 1 {
                        Divider()
                            .foregroundStyle(Color.spotterBorder)
                    }
                }
            }

            // Best Set Summary
            if let bestSet = sets.max(by: { OneRepMaxCalculator.estimate(from: $0) < OneRepMaxCalculator.estimate(from: $1) }) {
                HStack {
                    Text("Best e1RM")
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextSecondary)
                    Spacer()
                    Text(String(format: "%.0f lbs", OneRepMaxCalculator.estimate(from: bestSet)))
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterPrimary)
                }
                .padding(.top, Spacing.sm)
            }
        }
        .padding(Spacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.spotterBorder, lineWidth: BorderWidth.thin)
        )
    }

    private var painTagsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Discomfort Noted")
                .font(.spotterLabel)
                .foregroundStyle(Color.spotterTextSecondary)

            HStack {
                ForEach(session.painTags, id: \.self) { tag in
                    Text(tag)
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterWarning)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .strokeBorder(Color.spotterWarning.opacity(0.5), lineWidth: BorderWidth.thin)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Notes")
                .font(.spotterLabel)
                .foregroundStyle(Color.spotterTextSecondary)

            Text(notes)
                .font(.spotterBody)
                .foregroundStyle(Color.spotterText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func rpeEmoji(_ rpe: Int) -> String {
        let emojis = ["😫", "😓", "😐", "💪", "🔥"]
        guard rpe >= 1 && rpe <= 5 else { return "" }
        return emojis[rpe - 1]
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
