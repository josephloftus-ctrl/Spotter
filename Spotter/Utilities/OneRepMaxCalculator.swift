import Foundation

enum OneRepMaxCalculator {
    /// Epley formula: 1RM = weight × (1 + reps/30)
    static func epley(weight: Double, reps: Int) -> Double {
        guard reps > 0 else { return weight }
        if reps == 1 { return weight }
        return weight * (1 + Double(reps) / 30)
    }

    /// Brzycki formula: 1RM = weight × (36 / (37 - reps))
    static func brzycki(weight: Double, reps: Int) -> Double {
        guard reps > 0 && reps < 37 else { return weight }
        if reps == 1 { return weight }
        return weight * (36 / Double(37 - reps))
    }

    /// Default formula (using Epley)
    static func estimate(weight: Double, reps: Int) -> Double {
        epley(weight: weight, reps: reps)
    }

    /// Calculate estimated 1RM from a SetEntry
    static func estimate(from set: SetEntry) -> Double {
        estimate(weight: set.weight, reps: set.reps)
    }

    /// Find best estimated 1RM from a collection of sets
    static func bestEstimate(from sets: [SetEntry]) -> Double? {
        guard !sets.isEmpty else { return nil }
        return sets.map { estimate(from: $0) }.max()
    }
}
