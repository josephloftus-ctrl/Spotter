import Foundation
import SwiftData

@Model
class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var muscleGroups: [String]
    var modality: ExerciseModality
    var notes: String?
    var isCustom: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \SetEntry.exercise)
    var sets: [SetEntry] = []

    init(
        id: UUID = UUID(),
        name: String,
        muscleGroups: [String] = [],
        modality: ExerciseModality = .other,
        notes: String? = nil,
        isCustom: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.muscleGroups = muscleGroups
        self.modality = modality
        self.notes = notes
        self.isCustom = isCustom
        self.createdAt = createdAt
    }
}
