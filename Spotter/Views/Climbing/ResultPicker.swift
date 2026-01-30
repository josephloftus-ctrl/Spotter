import SwiftUI

struct ResultPicker: View {
    @Binding var selectedResult: ClimbResult

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Result")
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            GlassEffectContainer(spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    ForEach(ClimbResult.allCases, id: \.self) { result in
                        ResultButton(
                            result: result,
                            isSelected: selectedResult == result
                        ) {
                            withAnimation(SpotterAnimation.quick) {
                                selectedResult = result
                            }
                            HapticManager.selection()
                        }
                    }
                }
            }
        }
    }
}

struct ResultButton: View {
    let result: ClimbResult
    let isSelected: Bool
    let action: () -> Void

    private var tintColor: Color {
        switch result {
        case .flash: return .spotterWarning
        case .send: return .spotterSuccess
        case .project: return .spotterPrimary
        case .fall: return .spotterTextMuted
        }
    }

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: result.icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(result.displayName)
                    .font(.spotterCaption)
            }
            .foregroundStyle(isSelected ? .white : Color.spotterTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
        }
        .buttonStyle(.glass(isSelected ? .regular.tint(tintColor).interactive() : .clear.interactive()))
        .animation(SpotterAnimation.quick, value: isSelected)
    }
}

#Preview {
    ZStack {
        Color.spotterBackground.ignoresSafeArea()

        ResultPicker(selectedResult: .constant(.send))
            .padding()
    }
}
