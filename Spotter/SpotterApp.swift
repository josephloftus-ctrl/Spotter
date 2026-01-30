import SwiftUI
import SwiftData

@main
struct SpotterApp: App {
    @StateObject private var healthKitManager = HealthKitManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self,
            Gym.self,
            Wall.self,
            Climb.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onAppear {
                    ExerciseSeeder.seedDefaultExercises(modelContext: sharedModelContainer.mainContext)
                    GymSeeder.seedDefaultGyms(modelContext: sharedModelContainer.mainContext)
                }
                .task {
                    // Request HealthKit authorization
                    _ = await healthKitManager.requestAuthorization()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
