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
            List {
                // Current Plan Section
                Section("Training Plan") {
                    if let plan = activePlan {
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text(plan.name)
                                    .font(.spotterBody)
                                    .foregroundStyle(Color.spotterText)
                                Text("\(plan.daysPerWeek) days/week")
                                    .font(.spotterCaption)
                                    .foregroundStyle(Color.spotterTextSecondary)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(Color.spotterSuccess)
                        }
                    } else {
                        Text("No active plan")
                            .foregroundStyle(Color.spotterTextSecondary)
                    }

                    Button("Create New Plan") {
                        showingPlanSetup = true
                    }
                    .foregroundStyle(Color.spotterPrimary)
                }

                // Exercise Library Section
                Section("Exercises") {
                    Button {
                        showingExerciseLibrary = true
                    } label: {
                        HStack {
                            Text("Exercise Library")
                                .foregroundStyle(Color.spotterText)
                            Spacer()
                            Text("\(exercises.count)")
                                .foregroundStyle(Color.spotterTextSecondary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.spotterTextSecondary)
                        }
                    }
                }

                // Preferences Section
                Section("Preferences") {
                    Picker("Weight Unit", selection: $weightUnit) {
                        Text("lbs").tag(WeightUnit.lbs.rawValue)
                        Text("kg").tag(WeightUnit.kg.rawValue)
                    }
                }

                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                            .foregroundStyle(Color.spotterText)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(Color.spotterTextSecondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.spotterBackground)
            .navigationTitle("Settings")
            .fullScreenCover(isPresented: $showingPlanSetup) {
                PlanSetupView()
            }
            .sheet(isPresented: $showingExerciseLibrary) {
                ExerciseLibraryView()
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
