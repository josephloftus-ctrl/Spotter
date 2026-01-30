import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plans: [TrainingPlan]
    @Query private var exercises: [Exercise]

    @AppStorage("preferredWeightUnit") private var weightUnit = WeightUnit.lbs.rawValue

    @State private var showingPlanSetup = false
    @State private var showingExerciseLibrary = false

    private var activePlan: TrainingPlan? {
        plans.first { $0.isActive }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Training Plan Section
                        planSection

                        // Exercise Library Section
                        exerciseSection

                        // Preferences Section
                        preferencesSection

                        // About Section
                        aboutSection
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SETTINGS")
                        .font(.system(size: 13, weight: .bold, design: .default))
                        .tracking(3)
                        .foregroundStyle(Color.spotterTextMuted)
                }
            }
            .fullScreenCover(isPresented: $showingPlanSetup) {
                PlanSetupView()
            }
            .sheet(isPresented: $showingExerciseLibrary) {
                ExerciseLibraryView()
            }
        }
    }

    private var planSection: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader("Training Plan")

                if let plan = activePlan {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.spotterSuccess.opacity(0.15))
                                .frame(width: 48, height: 48)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.spotterSuccess)
                        }

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text(plan.name)
                                .font(.spotterBodyMedium)
                                .foregroundStyle(Color.spotterText)

                            Text("\(plan.daysPerWeek) days/week")
                                .font(.spotterCaption)
                                .foregroundStyle(Color.spotterTextMuted)
                        }

                        Spacer()
                    }
                } else {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.spotterSurface)
                                .frame(width: 48, height: 48)

                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.spotterTextMuted)
                        }

                        Text("No active plan")
                            .font(.spotterBody)
                            .foregroundStyle(Color.spotterTextSecondary)

                        Spacer()
                    }
                }

                SpotterButton("Create New Plan", icon: "plus", style: .secondary) {
                    showingPlanSetup = true
                }
            }
        }
    }

    private var exerciseSection: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader("Exercise Library")

                Button {
                    showingExerciseLibrary = true
                    HapticManager.selection()
                } label: {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.spotterPrimaryMuted)
                                .frame(width: 48, height: 48)

                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.spotterPrimary)
                        }

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Browse Exercises")
                                .font(.spotterBodyMedium)
                                .foregroundStyle(Color.spotterText)

                            Text("\(exercises.count) exercises available")
                                .font(.spotterCaption)
                                .foregroundStyle(Color.spotterTextMuted)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.spotterTextMuted)
                    }
                }
            }
        }
    }

    private var preferencesSection: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader("Preferences")

                HStack {
                    Text("Weight Unit")
                        .font(.spotterBody)
                        .foregroundStyle(Color.spotterText)

                    Spacer()

                    Picker("Weight Unit", selection: $weightUnit) {
                        Text("lbs").tag(WeightUnit.lbs.rawValue)
                        Text("kg").tag(WeightUnit.kg.rawValue)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
            }
        }
    }

    private var aboutSection: some View {
        SpotterCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader("About")

                VStack(spacing: Spacing.sm) {
                    StatRow("Version", value: "1.0.0")
                    SpotterDivider()
                    StatRow("Build", value: "Production")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
        ], inMemory: true)
}
