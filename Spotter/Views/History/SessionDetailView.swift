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
                .padding()
            }
            .navigationTitle(DateFormatters.formatRelativeDate(session.date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var sessionHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if let planDayName = session.planDayName {
                Text(planDayName)
                    .font(.spotterHeadline)
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
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func exerciseSection(name: String, sets: [SetEntry]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(name)
                .font(.spotterHeadline)

            ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                HStack {
                    Text("Set \(index + 1)")
                        .font(.spotterBody)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(set.displayWeight) × \(set.reps)")
                        .font(.spotterBody)
                    if let rpe = set.rpe {
                        Text("@\(rpe)")
                            .font(.spotterCaption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Best Set Summary
            if let bestSet = sets.max(by: { OneRepMaxCalculator.estimate(from: $0) < OneRepMaxCalculator.estimate(from: $1) }) {
                HStack {
                    Text("Best e1RM")
                        .font(.spotterCaption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.0f lbs", OneRepMaxCalculator.estimate(from: bestSet)))
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterPrimaryFallback)
                }
                .padding(.top, Spacing.xs)
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var painTagsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Discomfort Noted")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            HStack {
                ForEach(session.painTags, id: \.self) { tag in
                    Text(tag)
                        .font(.spotterCaption)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.spotterWarningFallback.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Notes")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            Text(notes)
                .font(.spotterBody)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
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
