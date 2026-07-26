import Foundation

@MainActor
final class WorkoutWatchSync {
    private let connectivity = WorkoutConnectivity()

    func start() {
        connectivity.activate()
    }

    func send(workouts: [Workout], recovery: RecoveryAdvice) {
        let transferWorkouts = workouts.map {
            WorkoutTransfer(
                id: $0.id,
                date: $0.date,
                activity: $0.activity.rawValue,
                durationMinutes: $0.durationMinutes,
                distanceMeters: $0.distanceMeters,
                elevationGainMeters: $0.elevationGainMeters
            )
        }

        let snapshot = AppSnapshotTransfer(
            workouts: transferWorkouts,
            recovery: RecoveryTransfer(
                locationName: recovery.locationName,
                altitudeMeters: recovery.altitudeMeters,
                headline: recovery.headline,
                recommendation: recovery.recommendation,
                systemImage: recovery.systemImage
            )
        )

        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }
        connectivity.sendLatest(data)
    }
}
