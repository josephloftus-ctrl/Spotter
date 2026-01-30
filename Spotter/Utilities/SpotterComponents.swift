import SwiftUI

// MARK: - Primary Button

struct SpotterButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void

    @State private var isPressed = false

    enum ButtonStyle {
        case primary    // Gradient fill, main CTAs
        case secondary  // Bordered, secondary actions
        case ghost      // Text only, tertiary
    }

    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.buttonTap()
            action()
        } label: {
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
            .background(backgroundView)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .overlay(overlayView)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: { isPressed = true }, onRelease: { isPressed = false })
        .animation(SpotterAnimation.quick, value: isPressed)
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            LinearGradient.spotterPrimaryGradient
        case .secondary:
            Color.clear
        case .ghost:
            Color.clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .ghost:
            return .spotterPrimary
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch style {
        case .primary:
            EmptyView()
        case .secondary:
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(Color.spotterPrimary, lineWidth: BorderWidth.medium)
        case .ghost:
            EmptyView()
        }
    }
}

// MARK: - Card Container

struct SpotterCard<Content: View>: View {
    let content: Content
    var accentEdge: Edge?
    var padding: CGFloat

    init(
        accentEdge: Edge? = nil,
        padding: CGFloat = Spacing.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.accentEdge = accentEdge
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    Color.spotterSurfaceElevated
                    LinearGradient.spotterCardHighlight
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(Color.spotterBorder, lineWidth: BorderWidth.thin)
            )
            .overlay(alignment: accentAlignment) {
                if accentEdge != nil {
                    accentBar
                }
            }
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

// MARK: - Chip / Pill Selector

struct SpotterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            Text(label)
                .font(.spotterCaptionMedium)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient.spotterPrimaryGradient
                        } else {
                            Color.spotterSurface
                        }
                    }
                )
                .foregroundStyle(isSelected ? .white : Color.spotterTextSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isSelected ? Color.clear : Color.spotterBorder,
                            lineWidth: BorderWidth.thin
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: { isPressed = true }, onRelease: { isPressed = false })
        .animation(SpotterAnimation.quick, value: isPressed)
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

// MARK: - Stepper Button

struct SpotterStepper: View {
    @Binding var value: Double
    let step: Double
    let range: ClosedRange<Double>
    let label: String
    let unit: String

    var body: some View {
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

struct StepperButton: View {
    let icon: String
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isEnabled ? Color.spotterPrimary : Color.spotterTextMuted)
                .frame(width: 52, height: 52)
                .background(Color.spotterSurface)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(
                            isEnabled ? Color.spotterPrimary.opacity(0.3) : Color.spotterBorder,
                            lineWidth: BorderWidth.thin
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: { isPressed = true }, onRelease: { isPressed = false })
        .animation(SpotterAnimation.bounce, value: isPressed)
    }
}

// MARK: - RPE Selector

struct RPESelector: View {
    @Binding var selectedRPE: Int?

    private let rpeValues = [6, 7, 8, 9, 10]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("RPE (optional)")
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)

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

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            Text("\(value)")
                .font(.spotterBodyMedium)
                .foregroundStyle(isSelected ? .white : Color.spotterTextSecondary)
                .frame(width: 44, height: 44)
                .background(
                    Group {
                        if isSelected {
                            color
                        } else {
                            Color.spotterSurface
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .strokeBorder(
                            isSelected ? color : Color.spotterBorder,
                            lineWidth: BorderWidth.thin
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: { isPressed = true }, onRelease: { isPressed = false })
        .animation(SpotterAnimation.bounce, value: isPressed)
        .animation(SpotterAnimation.quick, value: isSelected)
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let size: CGFloat

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.spotterBorder, lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient.spotterPrimaryGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(SpotterAnimation.standard, value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Empty State

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

// MARK: - Animated Checkmark

struct AnimatedCheckmark: View {
    let isComplete: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isComplete ? Color.spotterSuccess : Color.spotterSurface)
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .strokeBorder(
                            isComplete ? Color.spotterSuccess : Color.spotterBorder,
                            lineWidth: BorderWidth.thin
                        )
                )

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

// MARK: - Divider

struct SpotterDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.spotterBorder)
            .frame(height: 1)
    }
}
