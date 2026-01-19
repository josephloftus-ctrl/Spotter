import SwiftUI

struct SessionCompleteView: View {
    @Environment(\.modelContext) private var modelContext
    let session: Session
    let onComplete: () -> Void

    @State private var sessionRPE: Int = 3
    @State private var selectedPainTags: Set<String> = []
    @State private var notes: String = ""

    private let painTagOptions = [
        "Shoulders", "Lower Back", "Upper Back", "Knees",
        "Elbows", "Wrists", "Hips", "Neck"
    ]

    private let rpeEmojis = ["😫", "😓", "😐", "💪", "🔥"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Session Summary
                    sessionSummary

                    // Feel Rating
                    feelRating

                    // Pain Tags
                    painTagSection

                    // Notes
                    notesSection
                }
                .padding()
            }
            .navigationTitle("Session Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveSession()
                    }
                    .font(.headline)
                }
            }
        }
    }

    private var sessionSummary: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.spotterSuccessFallback)

            if let duration = session.duration {
                Text(DateFormatters.formatDuration(duration))
                    .font(.spotterTitle)
            }

            HStack(spacing: Spacing.lg) {
                statItem(value: "\(session.sets.count)", label: "sets")
                statItem(value: "\(session.exerciseCount)", label: "exercises")
                statItem(value: formatVolume(session.totalVolume), label: "volume")
            }
        }
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack {
            Text(value)
                .font(.spotterHeadline)
            Text(label)
                .font(.spotterCaption)
                .foregroundStyle(.secondary)
        }
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }

    private var feelRating: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("How did it feel?")
                .font(.spotterHeadline)

            HStack(spacing: Spacing.md) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        sessionRPE = rating
                        HapticManager.selection()
                    } label: {
                        Text(rpeEmojis[rating - 1])
                            .font(.system(size: 32))
                            .padding(Spacing.sm)
                            .background(sessionRPE == rating ? Color.spotterPrimaryFallback.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var painTagSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Any discomfort?")
                .font(.spotterHeadline)

            Text("Optional — helps track patterns")
                .font(.spotterCaption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: Spacing.sm) {
                ForEach(painTagOptions, id: \.self) { tag in
                    Button {
                        togglePainTag(tag)
                        HapticManager.selection()
                    } label: {
                        Text(tag)
                            .font(.spotterBody)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(selectedPainTags.contains(tag) ? Color.spotterWarningFallback : Color.spotterSurfaceFallback)
                            .foregroundStyle(selectedPainTags.contains(tag) ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Notes")
                .font(.spotterHeadline)

            TextField("Optional notes...", text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.spotterSurfaceFallback)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }

    private func togglePainTag(_ tag: String) {
        if selectedPainTags.contains(tag) {
            selectedPainTags.remove(tag)
        } else {
            selectedPainTags.insert(tag)
        }
    }

    private func saveSession() {
        session.sessionRPE = sessionRPE
        session.painTags = Array(selectedPainTags)
        session.notes = notes.isEmpty ? nil : notes
        session.completedAt = Date()

        HapticManager.completeSession()
        onComplete()
    }
}

// Simple flow layout for pain tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing

                self.size.width = max(self.size.width, x)
            }

            self.size.height = y + lineHeight
        }
    }
}

#Preview {
    let session = Session(duration: 3600)

    return SessionCompleteView(session: session) { }
}
