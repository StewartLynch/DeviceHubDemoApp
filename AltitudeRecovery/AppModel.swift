import Foundation
import Observation

@Observable
@MainActor
final class AppModel {
    let workouts: WorkoutStore
    let location: LocationService
    @ObservationIgnored private var watchSync: WorkoutWatchSync?

    init() {
        let workoutStore = WorkoutStore()
        let locationService = LocationService()
        let watchSync = WorkoutWatchSync()

        workouts = workoutStore
        location = locationService
        self.watchSync = watchSync

        workoutStore.onWorkoutsChanged = { [weak self] _ in
            self?.syncWatch()
        }
        locationService.onLocationChanged = { [weak self] _ in
            self?.syncWatch()
        }
        watchSync.start()
        syncWatch()
    }

    init(workouts: WorkoutStore, location: LocationService) {
        self.workouts = workouts
        self.location = location
        watchSync = nil
    }

    func resetSampleData() {
        workouts.resetSamples()
    }

    private func syncWatch() {
        watchSync?.send(
            workouts: workouts.workouts,
            recovery: location.advice
        )
    }
}
