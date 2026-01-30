import Foundation

enum SessionType: String, Codable, CaseIterable {
    case lifting
    case climbing

    var displayName: String {
        switch self {
        case .lifting: return "Lifting"
        case .climbing: return "Climbing"
        }
    }

    var icon: String {
        switch self {
        case .lifting: return "dumbbell.fill"
        case .climbing: return "mountain.2.fill"
        }
    }
}
