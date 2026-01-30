import Foundation
import SwiftData

struct GymSeeder {
    static func seedDefaultGyms(modelContext: ModelContext) {
        // Check if gyms already exist
        let descriptor = FetchDescriptor<Gym>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else {
            return // Already seeded
        }

        // Create default gym: Rockville in Ewing, NJ
        let rockville = Gym(
            name: "Rockville",
            city: "Ewing",
            state: "NJ",
            isDefault: true
        )
        modelContext.insert(rockville)

        // Create walls for Rockville
        let mainBoulder = Wall(
            name: "Main Boulder",
            wallType: .boulder,
            gym: rockville
        )

        let topRopeWall = Wall(
            name: "Top Rope Wall",
            wallType: .topRope,
            gym: rockville
        )

        let leadWall = Wall(
            name: "Lead Wall",
            wallType: .lead,
            gym: rockville
        )

        modelContext.insert(mainBoulder)
        modelContext.insert(topRopeWall)
        modelContext.insert(leadWall)

        try? modelContext.save()
        print("Seeded default gym: Rockville with 3 walls")
    }

    static func getDefaultGym(modelContext: ModelContext) -> Gym? {
        let descriptor = FetchDescriptor<Gym>(
            predicate: #Predicate { $0.isDefault }
        )
        return try? modelContext.fetch(descriptor).first
    }
}
