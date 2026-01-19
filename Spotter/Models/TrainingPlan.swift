import Foundation
import SwiftData

@Model
class TrainingPlan {
    @Attribute(.unique) var id: UUID
    var name: String
    var daysPerWeek: Int
    var isActive: Bool
    var createdAt: Date
    var notes: String?

    @Relationship(deleteRule: .cascade, inverse: \PlanDay.plan)
    var days: [PlanDay] = []

    init(
        id: UUID = UUID(),
        name: String,
        daysPerWeek: Int = 3,
        isActive: Bool = false,
        createdAt: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.daysPerWeek = daysPerWeek
        self.isActive = isActive
        self.createdAt = createdAt
        self.notes = notes
    }

    var sortedDays: [PlanDay] {
        days.sorted { $0.orderIndex < $1.orderIndex }
    }
}
