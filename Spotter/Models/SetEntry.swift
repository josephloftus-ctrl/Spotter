import Foundation
import SwiftData

@Model
class SetEntry {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise?
    var session: Session?
    var weight: Double
    var weightUnit: WeightUnit
    var reps: Int
    var rpe: Int?
    var notes: String?
    var timestamp: Date
    var orderIndex: Int

    init(
        id: UUID = UUID(),
        exercise: Exercise? = nil,
        session: Session? = nil,
        weight: Double,
        weightUnit: WeightUnit = .lbs,
        reps: Int,
        rpe: Int? = nil,
        notes: String? = nil,
        timestamp: Date = Date(),
        orderIndex: Int = 0
    ) {
        self.id = id
        self.exercise = exercise
        self.session = session
        self.weight = weight
        self.weightUnit = weightUnit
        self.reps = reps
        self.rpe = rpe
        self.notes = notes
        self.timestamp = timestamp
        self.orderIndex = orderIndex
    }

    var volume: Double {
        weight * Double(reps)
    }

    var displayWeight: String {
        let formatted = weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
        return "\(formatted) \(weightUnit.displayName)"
    }
}
