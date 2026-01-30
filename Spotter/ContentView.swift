import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

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

            // Custom tab bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabBarItem(icon: "flame.fill", label: "Today", index: 0)
            tabBarItem(icon: "clock.fill", label: "History", index: 1)
            tabBarItem(icon: "chart.line.uptrend.xyaxis", label: "Trends", index: 2)
            tabBarItem(icon: "gearshape.fill", label: "Settings", index: 3)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xs)
        .background(
            Rectangle()
                .fill(Color.spotterSurface)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.spotterBorder)
                        .frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabBarItem(icon: String, label: String, index: Int) -> some View {
        let isSelected = selectedTab == index

        return Button {
            withAnimation(SpotterAnimation.quick) {
                selectedTab = index
            }
            HapticManager.selection()
        } label: {
            VStack(spacing: Spacing.xxs) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color.spotterPrimaryMuted)
                            .frame(width: 56, height: 32)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color.spotterPrimary : Color.spotterTextMuted)
                }

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color.spotterPrimary : Color.spotterTextMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
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
