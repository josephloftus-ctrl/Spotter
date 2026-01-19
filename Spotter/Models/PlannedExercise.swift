import Foundation
import SwiftData

@Model
class PlannedExercise {
    @Attribute(.unique) var id: UUID
    var exerciseName: String
    var sets: Int
    var reps: String
    var notes: String?
    var orderIndex: Int
    var planDay: PlanDay?
    var exerciseId: UUID?

    init(
        id: UUID = UUID(),
        exerciseName: String,
        sets: Int = 3,
        reps: String = "8-12",
        notes: String? = nil,
        orderIndex: Int = 0,
        planDay: PlanDay? = nil,
        exerciseId: UUID? = nil
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.sets = sets
        self.reps = reps
        self.notes = notes
        self.orderIndex = orderIndex
        self.planDay = planDay
        self.exerciseId = exerciseId
    }

    var displayPrescription: String {
        "\(sets) × \(reps)"
    }
}
