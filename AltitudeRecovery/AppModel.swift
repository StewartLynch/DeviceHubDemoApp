import Foundation
import Observation

@Observable
@MainActor
final class AppModel {
    let workouts: WorkoutStore
    let location: LocationService

    init() {
        workouts = WorkoutStore()
        location = LocationService()
    }

    init(workouts: WorkoutStore, location: LocationService) {
        self.workouts = workouts
        self.location = location
    }

    func resetSampleData() {
        workouts.resetSamples()
    }
}
