import Foundation
import SwiftData

struct ExerciseSeeder {
    struct ExerciseData: Codable {
        let name: String
        let modality: String
        let muscleGroups: [String]
    }

    struct ExercisesFile: Codable {
        let exercises: [ExerciseData]
    }

    static func seedDefaultExercises(modelContext: ModelContext) {
        // Check if exercises already exist
        let descriptor = FetchDescriptor<Exercise>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else {
            return // Already seeded
        }

        // Load JSON
        guard let url = Bundle.main.url(forResource: "DefaultExercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let exercisesFile = try? JSONDecoder().decode(ExercisesFile.self, from: data) else {
            print("Failed to load default exercises")
            return
        }

        // Create exercises
        for exerciseData in exercisesFile.exercises {
            let modality = ExerciseModality(rawValue: exerciseData.modality) ?? .other

            let exercise = Exercise(
                name: exerciseData.name,
                muscleGroups: exerciseData.muscleGroups,
                modality: modality,
                isCustom: false
            )

            modelContext.insert(exercise)
        }

        try? modelContext.save()
        print("Seeded \(exercisesFile.exercises.count) default exercises")
    }
}
