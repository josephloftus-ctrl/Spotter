import Foundation

enum GradeSystem: String, Codable, CaseIterable {
    case vScale    // Bouldering (V0-V17)
    case yds       // Yosemite Decimal System (5.0-5.15d)

    var displayName: String {
        switch self {
        case .vScale: return "V-Scale"
        case .yds: return "YDS"
        }
    }
}

struct ClimbingGrade: Codable, Hashable {
    let system: GradeSystem
    let value: String

    var displayValue: String {
        value
    }

    // V-Scale grades for bouldering
    static let vScaleGrades: [ClimbingGrade] = [
        "VB", "V0", "V1", "V2", "V3", "V4", "V5", "V6",
        "V7", "V8", "V9", "V10", "V11", "V12"
    ].map { ClimbingGrade(system: .vScale, value: $0) }

    // YDS grades for roped climbing
    static let ydsGrades: [ClimbingGrade] = [
        "5.5", "5.6", "5.7", "5.8", "5.9",
        "5.10a", "5.10b", "5.10c", "5.10d",
        "5.11a", "5.11b", "5.11c", "5.11d",
        "5.12a", "5.12b", "5.12c", "5.12d"
    ].map { ClimbingGrade(system: .yds, value: $0) }

    static func grades(for system: GradeSystem) -> [ClimbingGrade] {
        switch system {
        case .vScale: return vScaleGrades
        case .yds: return ydsGrades
        }
    }
}

enum ClimbResult: String, Codable, CaseIterable {
    case flash    // First attempt success
    case send     // Clean send (after previous attempts)
    case project  // Working on it, not sent
    case fall     // Fell/didn't complete

    var displayName: String {
        switch self {
        case .flash: return "Flash"
        case .send: return "Send"
        case .project: return "Project"
        case .fall: return "Fall"
        }
    }

    var icon: String {
        switch self {
        case .flash: return "bolt.fill"
        case .send: return "checkmark.circle.fill"
        case .project: return "arrow.triangle.2.circlepath"
        case .fall: return "arrow.down.circle"
        }
    }

    var color: String {
        switch self {
        case .flash: return "spotterWarning"   // Gold/amber for flash
        case .send: return "spotterSuccess"    // Green for send
        case .project: return "spotterPrimary" // Cyan for project
        case .fall: return "spotterTextMuted"  // Muted for fall
        }
    }
}

enum WallType: String, Codable, CaseIterable {
    case boulder
    case topRope
    case lead
    case autoBelay

    var displayName: String {
        switch self {
        case .boulder: return "Boulder"
        case .topRope: return "Top Rope"
        case .lead: return "Lead"
        case .autoBelay: return "Auto Belay"
        }
    }

    var icon: String {
        switch self {
        case .boulder: return "square.stack.3d.up"
        case .topRope: return "arrow.up.to.line"
        case .lead: return "arrow.up.forward"
        case .autoBelay: return "arrow.up.circle"
        }
    }

    var defaultGradeSystem: GradeSystem {
        switch self {
        case .boulder: return .vScale
        case .topRope, .lead, .autoBelay: return .yds
        }
    }
}
