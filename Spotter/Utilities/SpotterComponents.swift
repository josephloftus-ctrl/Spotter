import SwiftUI

// MARK: - Primary Button (Liquid Glass)

struct SpotterButton: View {
    let title: String
    let icon: String?
    let style: SpotterButtonStyle
    let action: () -> Void

    enum SpotterButtonStyle {
        case primary    // Glass with tint, main CTAs
        case secondary  // Clear glass, secondary actions
        case ghost      // Text only, tertiary
    }

    init(_ title: String, icon: String? = nil, style: SpotterButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        switch style {
        case .primary:
            primaryButton
        case .secondary:
            secondaryButton
        case .ghost:
            ghostButton
        }
    }

    private var buttonLabel: some View {
        HStack(spacing: Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
            }
            Text(title)
                .font(.spotterLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.lg)
    }

    private var primaryButton: some View {
        Button {
            HapticManager.buttonTap()
            action()
        } label: {
            buttonLabel
        }
        .buttonStyle(.glass(.regular.tint(.spotterPrimary).interactive()))
    }

    private var secondaryButton: some View {
        Button {
            HapticManager.buttonTap()
            action()
        } label: {
            buttonLabel
        }
        .buttonStyle(.glass(.clear.interactive()))
    }

    private var ghostButton: some View {
        Button {
            HapticManager.buttonTap()
            action()
        } label: {
            buttonLabel
                .foregroundStyle(Color.spotterPrimary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Card Container (Liquid Glass)

struct SpotterCard<Content: View>: View {
    let content: Content
    var accentEdge: Edge?
    var padding: CGFloat
    var tintColor: Color?

    init(
        accentEdge: Edge? = nil,
        padding: CGFloat = Spacing.lg,
        tint: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.accentEdge = accentEdge
        self.padding = padding
        self.tintColor = tint
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .glassEffect(glassStyle, in: RoundedRectangle(cornerRadius: CornerRadius.md))
            .overlay(alignment: accentAlignment) {
                if accentEdge != nil {
                    accentBar
                }
            }
    }

    private var glassStyle: Glass {
        if let tint = tintColor {
            return .regular.tint(tint)
        }
        return .regular
    }

    private var accentAlignment: Alignment {
        switch accentEdge {
        case .top: return .top
        case .leading: return .leading
        case .bottom: return .bottom
        case .trailing: return .trailing
        case .none: return .center
        }
    }

    @ViewBuilder
    private var accentBar: some View {
        switch accentEdge {
        case .top:
            Capsule()
                .fill(LinearGradient.spotterPrimaryGradient)
                .frame(width: 40, height: 3)
                .offset(y: -1)
        case .leading:
            Capsule()
                .fill(LinearGradient.spotterPrimaryGradient)
                .frame(width: 3, height: 40)
                .offset(x: -1)
        default:
            EmptyView()
        }
    }
}

// MARK: - Glass Effect Container Wrapper

struct SpotterGlassContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    init(spacing: CGFloat = Spacing.md, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        GlassEffectContainer(spacing: spacing) {
            content
        }
    }
}

// MARK: - Chip / Pill Selector (Liquid Glass)

struct SpotterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            Text(label)
                .font(.spotterCaptionMedium)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .foregroundStyle(isSelected ? .white : Color.spotterTextSecondary)
        }
        .buttonStyle(.glass(isSelected ? .regular.tint(.spotterPrimary).interactive() : .clear.interactive()))
        .animation(SpotterAnimation.quick, value: isSelected)
    }
}

// MARK: - Large Metric Display

struct MetricDisplay: View {
    let value: String
    let label: String
    let size: Size

    enum Size {
        case large   // Main workout numbers (weight, reps)
        case medium  // Secondary metrics
        case small   // Compact stats
    }

    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Text(value)
                .font(valueFont)
                .foregroundStyle(Color.spotterText)
                .contentTransition(.numericText())

            Text(label)
                .font(labelFont)
                .foregroundStyle(Color.spotterTextSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
    }

    private var valueFont: Font {
        switch size {
        case .large: return .spotterLargeNumber
        case .medium: return .spotterMediumNumber
        case .small: return .spotterHeadline
        }
    }

    private var labelFont: Font {
        switch size {
        case .large: return .spotterCaptionMedium
        case .medium: return .spotterCaption
        case .small: return .spotterCaption
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionLabel: String?

    init(_ title: String, subtitle: String? = nil, action: (() -> Void)? = nil, actionLabel: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.actionLabel = actionLabel
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.spotterHeadline)
                    .foregroundStyle(Color.spotterText)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextSecondary)
                }
            }

            Spacer()

            if let action = action, let label = actionLabel {
                Button {
                    action()
                } label: {
                    Text(label)
                        .font(.spotterCaptionMedium)
                        .foregroundStyle(Color.spotterPrimary)
                }
            }
        }
    }
}

// MARK: - Stepper Button (Liquid Glass)

struct SpotterStepper: View {
    @Binding var value: Double
    let step: Double
    let range: ClosedRange<Double>
    let label: String
    let unit: String

    var body: some View {
        GlassEffectContainer(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                // Decrement
                StepperButton(icon: "minus") {
                    if value - step >= range.lowerBound {
                        value -= step
                        HapticManager.selection()
                    }
                }
                .disabled(value <= range.lowerBound)

                // Value display
                VStack(spacing: Spacing.xxs) {
                    Text("\(Int(value))")
                        .font(.spotterLargeNumber)
                        .foregroundStyle(Color.spotterText)
                        .contentTransition(.numericText())
                        .animation(SpotterAnimation.quick, value: value)

                    Text(unit)
                        .font(.spotterCaptionMedium)
                        .foregroundStyle(Color.spotterTextMuted)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                .frame(minWidth: 100)

                // Increment
                StepperButton(icon: "plus") {
                    if value + step <= range.upperBound {
                        value += step
                        HapticManager.selection()
                    }
                }
                .disabled(value >= range.upperBound)
            }
        }
    }
}

struct StepperButton: View {
    let icon: String
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isEnabled ? Color.spotterPrimary : Color.spotterTextMuted)
                .frame(width: 52, height: 52)
        }
        .buttonStyle(.glass(isEnabled ? .regular.tint(.spotterPrimary.opacity(0.3)).interactive() : .clear))
        .disabled(!isEnabled)
    }
}

// MARK: - RPE Selector (Liquid Glass)

struct RPESelector: View {
    @Binding var selectedRPE: Int?

    private let rpeValues = [6, 7, 8, 9, 10]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("RPE (optional)")
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)

            GlassEffectContainer(spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    ForEach(rpeValues, id: \.self) { rpe in
                        RPEButton(
                            value: rpe,
                            isSelected: selectedRPE == rpe,
                            color: rpeColor(for: rpe)
                        ) {
                            selectedRPE = selectedRPE == rpe ? nil : rpe
                            HapticManager.selection()
                        }
                    }
                }
            }
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

struct RPEButton: View {
    let value: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text("\(value)")
                .font(.spotterBodyMedium)
                .foregroundStyle(isSelected ? .white : Color.spotterTextSecondary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.glass(isSelected ? .regular.tint(color).interactive() : .clear.interactive()))
        .animation(SpotterAnimation.quick, value: isSelected)
    }
}

// MARK: - Progress Ring (Liquid Glass Enhanced)

struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let size: CGFloat

    var body: some View {
        ZStack {
            // Glass background
            Circle()
                .glassEffect(.clear, in: Circle())

            // Background ring
            Circle()
                .stroke(Color.spotterBorder, lineWidth: lineWidth)
                .padding(2)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient.spotterPrimaryGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(2)
                .animation(SpotterAnimation.standard, value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Empty State (Liquid Glass)

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color.spotterTextMuted)
                .padding()
                .glassEffect(.clear, in: Circle())

            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(.spotterHeadline)
                    .foregroundStyle(Color.spotterText)

                Text(message)
                    .font(.spotterBody)
                    .foregroundStyle(Color.spotterTextSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                SpotterButton(actionTitle, style: .secondary) {
                    action()
                }
                .frame(maxWidth: 200)
            }
        }
        .padding(Spacing.xxl)
    }
}

// MARK: - Animated Checkmark (Liquid Glass)

struct AnimatedCheckmark: View {
    let isComplete: Bool

    var body: some View {
        ZStack {
            Circle()
                .frame(width: 24, height: 24)
                .glassEffect(isComplete ? .regular.tint(.spotterSuccess) : .clear, in: Circle())

            if isComplete {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(SpotterAnimation.bounce, value: isComplete)
    }
}

// MARK: - Press Events Modifier

struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let value: String
    let secondaryValue: String?

    init(_ label: String, value: String, secondaryValue: String? = nil) {
        self.label = label
        self.value = value
        self.secondaryValue = secondaryValue
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.spotterBody)
                .foregroundStyle(Color.spotterTextSecondary)

            Spacer()

            HStack(spacing: Spacing.xs) {
                Text(value)
                    .font(.spotterBodyMedium)
                    .foregroundStyle(Color.spotterText)

                if let secondary = secondaryValue {
                    Text(secondary)
                        .font(.spotterCaption)
                        .foregroundStyle(Color.spotterTextMuted)
                }
            }
        }
    }
}

// MARK: - Divider (Liquid Glass)

struct SpotterDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.spotterGlassBorder)
            .frame(height: 1)
    }
}

// MARK: - Glass Text Field

struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal

    var body: some View {
        TextField(placeholder, text: $text, axis: axis)
            .font(.spotterBody)
            .foregroundStyle(Color.spotterText)
            .padding(Spacing.sm)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: CornerRadius.sm))
    }
}

// MARK: - Glass Icon Button

struct GlassIconButton: View {
    let icon: String
    let tint: Color?
    let action: () -> Void

    init(_ icon: String, tint: Color? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.tint = tint
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint ?? Color.spotterTextSecondary)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.glass(.clear.interactive()))
    }
}

// MARK: - Glass Tab Bar Item

struct GlassTabItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(isSelected ? Color.spotterPrimary : Color.spotterTextMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
        }
        .buttonStyle(.plain)
    }
}
