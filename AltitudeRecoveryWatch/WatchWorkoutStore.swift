import Foundation
import Observation

@Observable
@MainActor
final class WatchWorkoutStore {
    private(set) var workouts: [WorkoutTransfer]
    private(set) var recovery: RecoveryTransfer
    private(set) var lastUpdated: Date?

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var connectivity: WorkoutConnectivity?

    private static let cachedDataKey = "cachedAppSnapshotData"
    private static let lastUpdatedKey = "workoutLastUpdated"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let cachedSnapshot = Self.loadCachedSnapshot(from: defaults)
        workouts = cachedSnapshot?.workouts ?? []
        recovery = cachedSnapshot?.recovery ?? .waiting
        lastUpdated = defaults.object(forKey: Self.lastUpdatedKey) as? Date

        let connectivity = WorkoutConnectivity { [weak self] data in
            Task { @MainActor in
                self?.accept(data)
            }
        }
        self.connectivity = connectivity
        connectivity.activate()
    }

    init(previewSnapshot: AppSnapshotTransfer) {
        defaults = .standard
        workouts = previewSnapshot.workouts
        recovery = previewSnapshot.recovery
        lastUpdated = .now
        connectivity = nil
    }

    private func accept(_ data: Data) {
        guard let decoded = try? JSONDecoder().decode(
            AppSnapshotTransfer.self,
            from: data
        ) else {
            return
        }

        workouts = decoded.workouts.sorted { $0.date > $1.date }
        recovery = decoded.recovery
        lastUpdated = .now
        defaults.set(data, forKey: Self.cachedDataKey)
        defaults.set(lastUpdated, forKey: Self.lastUpdatedKey)
    }

    private static func loadCachedSnapshot(
        from defaults: UserDefaults
    ) -> AppSnapshotTransfer? {
        guard
            let data = defaults.data(forKey: cachedDataKey),
            let decoded = try? JSONDecoder().decode(
                AppSnapshotTransfer.self,
                from: data
            )
        else {
            return nil
        }
        return decoded
    }
}
