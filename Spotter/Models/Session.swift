import Foundation
import SwiftData

@Model
class Session {
    @Attribute(.unique) var id: UUID
    var date: Date
    var planDayName: String?
    var duration: TimeInterval?
    var sessionRPE: Int?
    var notes: String?
    var painTags: [String]
    var completedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \SetEntry.session)
    var sets: [SetEntry] = []

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        planDayName: String? = nil,
        duration: TimeInterval? = nil,
        sessionRPE: Int? = nil,
        notes: String? = nil,
        painTags: [String] = [],
        completedAt: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.planDayName = planDayName
        self.duration = duration
        self.sessionRPE = sessionRPE
        self.notes = notes
        self.painTags = painTags
        self.completedAt = completedAt
    }

    var isCompleted: Bool {
        completedAt != nil
    }

    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }

    var exerciseCount: Int {
        Set(sets.compactMap { $0.exercise?.id }).count
    }
}
