import Foundation

enum WeightUnit: String, Codable, CaseIterable {
    case lbs
    case kg

    var displayName: String {
        switch self {
        case .lbs: return "lbs"
        case .kg: return "kg"
        }
    }
}
