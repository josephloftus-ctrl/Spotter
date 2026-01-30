import SwiftUI
import SwiftData

struct SessionCompleteView: View {
    @Environment(\.modelContext) private var modelContext
    let session: Session
    let onComplete: () -> Void

    @State private var sessionRPE: Int = 3
    @State private var selectedPainTags: Set<String> = []
    @State private var notes: String = ""
    @State private var showContent = false

    private let painTagOptions = [
        "Shoulders", "Lower Back", "Upper Back", "Knees",
        "Elbows", "Wrists", "Hips", "Neck"
    ]

    private let rpeLabels = ["Rough", "Hard", "Okay", "Good", "Great"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Session Summary - Hero Section
                        sessionSummary
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)

                        // Feel Rating
                        feelRating
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(SpotterAnimation.standard.delay(0.1), value: showContent)

                        // Pain Tags
                        painTagSection
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(SpotterAnimation.standard.delay(0.2), value: showContent)

                        // Notes
                        notesSection
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(SpotterAnimation.standard.delay(0.3), value: showContent)
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, 100)
                }
            }
            .safeAreaInset(edge: .bottom) {
                SpotterButton("Save Session", icon: "checkmark", style: .primary) {
                    saveSession()
                }
                .padding(Spacing.md)
                .background(Color.spotterBackground)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Session Complete")
                        .font(.spotterHeadline)
                        .foregroundStyle(Color.spotterText)
                }
            }
            .onAppear {
                withAnimation(SpotterAnimation.standard) {
                    showContent = true
                }
            }
        }
    }

    private var sessionSummary: some View {
        VStack(spacing: Spacing.lg) {
            // Success icon with glow effect
            ZStack {
                Circle()
                    .fill(Color.spotterSuccess.opacity(0.15))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(Color.spotterSuccess.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.spotterSuccess)
            }
            .spotterGlow()

            // Duration as hero metric
            if let duration = session.duration {
                VStack(spacing: Spacing.xxs) {
                    Text(DateFormatters.formatDuration(duration))
                        .font(.spotterDisplay)
                        .foregroundStyle(Color.spotterText)

                    Text("DURATION")
                        .font(.spotterCaptionMedium)
                        .foregroundStyle(Color.spotterTextMuted)
                        .tracking(1)
                }
            }

            // Stats row
            HStack(spacing: 0) {
                Spacer()
                summaryStatItem(
                    value: "\(session.sets.count)",
                    label: "Sets",
                    icon: "square.stack.fill"
                )
                Spacer()
                SpotterDivider()
                    .frame(height: 40)
                Spacer()
                summaryStatItem(
                    value: "\(session.exerciseCount)",
                    label: "Exercises",
                    icon: "dumbbell.fill"
                )
                Spacer()
                SpotterDivider()
                    .frame(height: 40)
                Spacer()
                summaryStatItem(
                    value: formatVolume(session.totalVolume),
                    label: "Volume",
                    icon: "scalemass.fill"
                )
                Spacer()
            }
            .padding(.vertical, Spacing.md)
            .background(Color.spotterSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
    }

    private func summaryStatItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.spotterMediumNumber)
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

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }

    private var feelRating: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader("How did it feel?")

                HStack(spacing: Spacing.sm) {
                    ForEach(1...5, id: \.self) { rating in
                        Button {
                            withAnimation(SpotterAnimation.bounce) {
                                sessionRPE = rating
                            }
                            HapticManager.selection()
                        } label: {
                            VStack(spacing: Spacing.xs) {
                                ZStack {
                                    Circle()
                                        .fill(sessionRPE == rating ? ratingColor(for: rating) : Color.spotterSurface)
                                        .frame(width: 52, height: 52)

                                    Circle()
                                        .strokeBorder(
                                            sessionRPE == rating ? ratingColor(for: rating) : Color.spotterBorder,
                                            lineWidth: sessionRPE == rating ? 2 : 1
                                        )
                                        .frame(width: 52, height: 52)

                                    Text("\(rating)")
                                        .font(.spotterHeadline)
                                        .foregroundStyle(sessionRPE == rating ? .white : Color.spotterTextSecondary)
                                }
                                .scaleEffect(sessionRPE == rating ? 1.1 : 1.0)

                                Text(rpeLabels[rating - 1])
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(sessionRPE == rating ? ratingColor(for: rating) : Color.spotterTextMuted)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func ratingColor(for rating: Int) -> Color {
        switch rating {
        case 1: return .spotterRPE10
        case 2: return .spotterRPE9
        case 3: return .spotterRPE8
        case 4: return .spotterRPE7
        case 5: return .spotterSuccess
        default: return .spotterTextSecondary
        }
    }

    private var painTagSection: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    SectionHeader("Any discomfort?")
                    Text("Optional — helps track patterns over time")
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)
                }

                FlowLayout(spacing: Spacing.sm) {
                    ForEach(painTagOptions, id: \.self) { tag in
                        SpotterChip(
                            label: tag,
                            isSelected: selectedPainTags.contains(tag)
                        ) {
                            togglePainTag(tag)
                        }
                    }
                }
            }
        }
    }

    private var notesSection: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                SectionHeader("Notes", subtitle: "Optional")

                TextField("How was the session?", text: $notes, axis: .vertical)
                    .font(.spotterBody)
                    .foregroundStyle(Color.spotterText)
                    .padding(Spacing.sm)
                    .background(Color.spotterSurface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .strokeBorder(Color.spotterBorder, lineWidth: BorderWidth.thin)
                    )
                    .lineLimit(3...6)
            }
        }
    }

    private func togglePainTag(_ tag: String) {
        withAnimation(SpotterAnimation.quick) {
            if selectedPainTags.contains(tag) {
                selectedPainTags.remove(tag)
            } else {
                selectedPainTags.insert(tag)
            }
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
