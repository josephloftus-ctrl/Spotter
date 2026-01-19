import Foundation

enum ExerciseModality: String, Codable, CaseIterable {
    case barbell
    case dumbbell
    case machine
    case cable
    case bodyweight
    case cardio
    case climb
    case other

    var displayName: String {
        switch self {
        case .barbell: return "Barbell"
        case .dumbbell: return "Dumbbell"
        case .machine: return "Machine"
        case .cable: return "Cable"
        case .bodyweight: return "Bodyweight"
        case .cardio: return "Cardio"
        case .climb: return "Climb"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .barbell: return "figure.strengthtraining.traditional"
        case .dumbbell: return "dumbbell.fill"
        case .machine: return "gearshape.fill"
        case .cable: return "cable.connector"
        case .bodyweight: return "figure.walk"
        case .cardio: return "heart.fill"
        case .climb: return "mountain.2.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
