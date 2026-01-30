import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @Namespace private var tabNamespace

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            TabView(selection: $selectedTab) {
                TodayView()
                    .tag(0)

                HistoryView()
                    .tag(1)

                TrendsView()
                    .tag(2)

                SettingsView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Liquid Glass tab bar
            glassTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    private var glassTabBar: some View {
        GlassEffectContainer(spacing: 0) {
            HStack(spacing: 0) {
                glassTabItem(icon: "flame.fill", label: "Today", index: 0)
                glassTabItem(icon: "clock.fill", label: "History", index: 1)
                glassTabItem(icon: "chart.line.uptrend.xyaxis", label: "Trends", index: 2)
                glassTabItem(icon: "gearshape.fill", label: "Settings", index: 3)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .glassEffect(.regular, in: Capsule())
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.xs)
    }

    private func glassTabItem(icon: String, label: String, index: Int) -> some View {
        let isSelected = selectedTab == index

        return Button {
            withAnimation(SpotterAnimation.quick) {
                selectedTab = index
            }
            HapticManager.selection()
        } label: {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .frame(width: 44, height: 28)
                    .glassEffect(
                        isSelected ? .regular.tint(.spotterPrimary).interactive() : .identity,
                        in: Capsule()
                    )

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? Color.spotterPrimary : Color.spotterTextMuted)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
