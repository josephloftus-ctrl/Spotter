import SwiftUI
import SwiftData

struct ClimbingSessionCompleteView: View {
    @Environment(\.modelContext) private var modelContext
    let session: Session
    let onComplete: () -> Void

    @State private var sessionRPE: Int = 3
    @State private var selectedPainTags: Set<String> = []
    @State private var notes: String = ""
    @State private var showContent = false

    private let painTagOptions = [
        "Fingers", "Forearms", "Shoulders", "Lower Back",
        "Elbows", "Wrists", "Knees", "Skin"
    ]

    private let rpeLabels = ["Rough", "Hard", "Okay", "Good", "Great"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Session Summary
                        sessionSummary
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)

                        // Heart Rate Stats (if available)
                        if session.averageHeartRate != nil || session.maxHeartRate != nil {
                            heartRateStats
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(SpotterAnimation.standard.delay(0.05), value: showContent)
                        }

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

                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 48))
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
                    value: "\(session.climbCount)",
                    label: "Climbs",
                    icon: "figure.climbing"
                )
                Spacer()
                SpotterDivider()
                    .frame(height: 40)
                Spacer()
                summaryStatItem(
                    value: "\(session.sendCount)",
                    label: "Sends",
                    icon: "checkmark.circle.fill"
                )
                Spacer()
                SpotterDivider()
                    .frame(height: 40)
                Spacer()
                summaryStatItem(
                    value: session.hardestSend?.displayValue ?? "--",
                    label: "Hardest",
                    icon: "arrow.up.circle.fill"
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

    private var heartRateStats: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                    Text("Heart Rate")
                        .font(.spotterHeadline)
                        .foregroundStyle(Color.spotterText)
                }

                HStack(spacing: Spacing.xl) {
                    if let avgHR = session.averageHeartRate {
                        VStack(spacing: Spacing.xxs) {
                            Text(String(format: "%.0f", avgHR))
                                .font(.spotterMediumNumber)
                                .foregroundStyle(Color.spotterText)
                            Text("AVG BPM")
                                .font(.spotterCaption)
                                .foregroundStyle(Color.spotterTextMuted)
                        }
                    }

                    if let maxHR = session.maxHeartRate {
                        VStack(spacing: Spacing.xxs) {
                            Text(String(format: "%.0f", maxHR))
                                .font(.spotterMediumNumber)
                                .foregroundStyle(Color.spotterError)
                            Text("MAX BPM")
                                .font(.spotterCaption)
                                .foregroundStyle(Color.spotterTextMuted)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
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

#Preview {
    let session = Session(
        duration: 3600,
        sessionType: .climbing,
        averageHeartRate: 125,
        maxHeartRate: 165
    )

    return ClimbingSessionCompleteView(session: session) { }
}
