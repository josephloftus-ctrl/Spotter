import Foundation
import SwiftData

@Model
class Wall {
    @Attribute(.unique) var id: UUID
    var name: String
    var wallTypeRaw: String
    var gym: Gym?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Climb.wall)
    var climbs: [Climb] = []

    var wallType: WallType {
        get { WallType(rawValue: wallTypeRaw) ?? .boulder }
        set { wallTypeRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        wallType: WallType,
        gym: Gym? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.wallTypeRaw = wallType.rawValue
        self.gym = gym
        self.createdAt = createdAt
    }

    var defaultGradeSystem: GradeSystem {
        wallType.defaultGradeSystem
    }
}
