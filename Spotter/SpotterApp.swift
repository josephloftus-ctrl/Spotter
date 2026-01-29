import SwiftUI
import SwiftData

@main
struct SpotterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            Session.self,
            SetEntry.self,
            TrainingPlan.self,
            PlanDay.self,
            PlannedExercise.self
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
                .preferredColorScheme(.light)
                .onAppear {
                    ExerciseSeeder.seedDefaultExercises(modelContext: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
