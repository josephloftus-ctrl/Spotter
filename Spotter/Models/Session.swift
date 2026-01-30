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

    // Session type discriminator
    var sessionTypeRaw: String = SessionType.lifting.rawValue

    // Heart rate data (from HealthKit)
    var averageHeartRate: Double?
    var maxHeartRate: Double?
    var activeCalories: Double?

    @Relationship(deleteRule: .cascade, inverse: \SetEntry.session)
    var sets: [SetEntry] = []

    // Climbing-specific relationships
    var gym: Gym?

    @Relationship(deleteRule: .cascade, inverse: \Climb.session)
    var climbs: [Climb] = []

    var sessionType: SessionType {
        get { SessionType(rawValue: sessionTypeRaw) ?? .lifting }
        set { sessionTypeRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        planDayName: String? = nil,
        duration: TimeInterval? = nil,
        sessionRPE: Int? = nil,
        notes: String? = nil,
        painTags: [String] = [],
        completedAt: Date? = nil,
        sessionType: SessionType = .lifting,
        gym: Gym? = nil,
        averageHeartRate: Double? = nil,
        maxHeartRate: Double? = nil,
        activeCalories: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.planDayName = planDayName
        self.duration = duration
        self.sessionRPE = sessionRPE
        self.notes = notes
        self.painTags = painTags
        self.completedAt = completedAt
        self.sessionTypeRaw = sessionType.rawValue
        self.gym = gym
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.activeCalories = activeCalories
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

    // Climbing-specific computed properties
    var climbCount: Int {
        climbs.count
    }

    var sendCount: Int {
        climbs.filter { $0.isSent }.count
    }

    var flashCount: Int {
        climbs.filter { $0.result == .flash }.count
    }

    var hardestSend: ClimbingGrade? {
        climbs
            .filter { $0.isSent }
            .map { $0.grade }
            .max { gradeCompare($0, $1) }
    }

    private func gradeCompare(_ a: ClimbingGrade, _ b: ClimbingGrade) -> Bool {
        // Simple comparison by index in the grade list
        let aIndex = ClimbingGrade.grades(for: a.system).firstIndex(where: { $0.value == a.value }) ?? 0
        let bIndex = ClimbingGrade.grades(for: b.system).firstIndex(where: { $0.value == b.value }) ?? 0
        return aIndex < bIndex
    }
}
