import Foundation
import SwiftData

@Model
class PlanDay {
    @Attribute(.unique) var id: UUID
    var name: String
    var orderIndex: Int
    var plan: TrainingPlan?

    @Relationship(deleteRule: .cascade, inverse: \PlannedExercise.planDay)
    var exercises: [PlannedExercise] = []

    init(
        id: UUID = UUID(),
        name: String,
        orderIndex: Int = 0,
        plan: TrainingPlan? = nil
    ) {
        self.id = id
        self.name = name
        self.orderIndex = orderIndex
        self.plan = plan
    }

    var sortedExercises: [PlannedExercise] {
        exercises.sorted { $0.orderIndex < $1.orderIndex }
    }
}
