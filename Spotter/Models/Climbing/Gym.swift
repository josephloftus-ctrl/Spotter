import Foundation
import SwiftData

@Model
class Gym {
    @Attribute(.unique) var id: UUID
    var name: String
    var city: String
    var state: String
    var isDefault: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Wall.gym)
    var walls: [Wall] = []

    init(
        id: UUID = UUID(),
        name: String,
        city: String,
        state: String,
        isDefault: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.city = city
        self.state = state
        self.isDefault = isDefault
        self.createdAt = createdAt
    }

    var displayLocation: String {
        "\(city), \(state)"
    }

    var sortedWalls: [Wall] {
        walls.sorted { $0.name < $1.name }
    }
}
