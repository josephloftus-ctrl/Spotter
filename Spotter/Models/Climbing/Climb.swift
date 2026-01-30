import Foundation
import SwiftData

@Model
class Climb {
    @Attribute(.unique) var id: UUID
    var gradeSystem: String
    var gradeValue: String
    var resultRaw: String
    var attempts: Int
    var notes: String?
    var timestamp: Date
    var orderIndex: Int

    var session: Session?
    var wall: Wall?

    var grade: ClimbingGrade {
        get {
            ClimbingGrade(
                system: GradeSystem(rawValue: gradeSystem) ?? .vScale,
                value: gradeValue
            )
        }
        set {
            gradeSystem = newValue.system.rawValue
            gradeValue = newValue.value
        }
    }

    var result: ClimbResult {
        get { ClimbResult(rawValue: resultRaw) ?? .send }
        set { resultRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        grade: ClimbingGrade,
        result: ClimbResult,
        attempts: Int = 1,
        notes: String? = nil,
        session: Session? = nil,
        wall: Wall? = nil,
        timestamp: Date = Date(),
        orderIndex: Int = 0
    ) {
        self.id = id
        self.gradeSystem = grade.system.rawValue
        self.gradeValue = grade.value
        self.resultRaw = result.rawValue
        self.attempts = attempts
        self.notes = notes
        self.session = session
        self.wall = wall
        self.timestamp = timestamp
        self.orderIndex = orderIndex
    }

    var displayGrade: String {
        grade.displayValue
    }

    var isSent: Bool {
        result == .send || result == .flash
    }
}
