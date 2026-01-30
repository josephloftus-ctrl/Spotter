import SwiftUI
import SwiftData

struct WallSelector: View {
    let walls: [Wall]
    @Binding var selectedWall: Wall?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Wall")
                .font(.spotterCaption)
                .foregroundStyle(Color.spotterTextSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(walls) { wall in
                        WallChip(
                            wall: wall,
                            isSelected: selectedWall?.id == wall.id
                        ) {
                            withAnimation(SpotterAnimation.quick) {
                                selectedWall = wall
                            }
                            HapticManager.selection()
                        }
                    }
                }
            }
        }
    }
}

struct WallChip: View {
    let wall: Wall
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: wall.wallType.icon)
                    .font(.system(size: 14))
                Text(wall.name)
                    .font(.spotterCaptionMedium)
            }
            .foregroundStyle(isSelected ? .white : Color.spotterTextSecondary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
        .buttonStyle(.glass(isSelected ? .regular.tint(.spotterPrimary).interactive() : .clear.interactive()))
        .animation(SpotterAnimation.quick, value: isSelected)
    }
}

#Preview {
    ZStack {
        Color.spotterBackground.ignoresSafeArea()

        WallSelector(
            walls: [],
            selectedWall: .constant(nil)
        )
        .padding()
    }
}
