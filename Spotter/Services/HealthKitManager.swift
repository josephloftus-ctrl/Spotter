import Foundation
import HealthKit

@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var workoutSession: HKWorkoutSession?

    @Published var currentHeartRate: Double?
    @Published var heartRateSamples: [Double] = []
    @Published var isAuthorized = false
    @Published var isMonitoring = false

    private init() {}

    // MARK: - Authorization

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async -> Bool {
        guard isHealthKitAvailable else {
            print("HealthKit not available on this device")
            return false
        }

        let heartRateType = HKQuantityType(.heartRate)
        let activeEnergyType = HKQuantityType(.activeEnergyBurned)
        let workoutType = HKWorkoutType.workoutType()

        let typesToRead: Set<HKObjectType> = [heartRateType, activeEnergyType, workoutType]
        let typesToWrite: Set<HKSampleType> = [workoutType]

        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            isAuthorized = true
            return true
        } catch {
            print("HealthKit authorization failed: \(error)")
            return false
        }
    }

    // MARK: - Heart Rate Monitoring

    func startHeartRateMonitoring() {
        guard isAuthorized else {
            print("HealthKit not authorized")
            return
        }

        heartRateSamples = []
        currentHeartRate = nil

        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: Date(),
            end: nil,
            options: .strictStartDate
        )

        heartRateQuery = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, error in
            guard error == nil else {
                print("Heart rate query error: \(error!)")
                return
            }
            self?.processHeartRateSamples(samples)
        }

        heartRateQuery?.updateHandler = { [weak self] _, samples, _, _, error in
            guard error == nil else {
                print("Heart rate update error: \(error!)")
                return
            }
            self?.processHeartRateSamples(samples)
        }

        if let query = heartRateQuery {
            healthStore.execute(query)
            isMonitoring = true
            print("Started heart rate monitoring")
        }
    }

    func stopMonitoring() -> HeartRateStats {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }

        isMonitoring = false

        let stats = calculateStats()
        print("Stopped monitoring. Avg HR: \(stats.average ?? 0), Max HR: \(stats.max ?? 0)")

        // Reset state
        let finalStats = stats
        heartRateSamples = []
        currentHeartRate = nil

        return finalStats
    }

    private nonisolated func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }

        let hrUnit = HKUnit.count().unitDivided(by: .minute())

        for sample in heartRateSamples {
            let heartRate = sample.quantity.doubleValue(for: hrUnit)

            Task { @MainActor in
                self.heartRateSamples.append(heartRate)
                self.currentHeartRate = heartRate
            }
        }
    }

    private func calculateStats() -> HeartRateStats {
        guard !heartRateSamples.isEmpty else {
            return HeartRateStats(average: nil, max: nil, samples: [])
        }

        let average = heartRateSamples.reduce(0, +) / Double(heartRateSamples.count)
        let max = heartRateSamples.max()

        return HeartRateStats(
            average: average,
            max: max,
            samples: heartRateSamples
        )
    }

    // MARK: - Active Calories

    func getActiveCalories(from startDate: Date, to endDate: Date) async -> Double? {
        let activeEnergyType = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: activeEnergyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                guard error == nil,
                      let sum = result?.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }

                let calories = sum.doubleValue(for: .kilocalorie())
                continuation.resume(returning: calories)
            }

            self.healthStore.execute(query)
        }
    }
}

// MARK: - Heart Rate Stats

struct HeartRateStats {
    let average: Double?
    let max: Double?
    let samples: [Double]

    var formattedAverage: String {
        guard let avg = average else { return "--" }
        return String(format: "%.0f", avg)
    }

    var formattedMax: String {
        guard let max = max else { return "--" }
        return String(format: "%.0f", max)
    }
}
