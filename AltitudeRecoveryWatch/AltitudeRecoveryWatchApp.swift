import SwiftUI

@main
struct AltitudeRecoveryWatchApp: App {
    @State private var workoutStore = WatchWorkoutStore()

    var body: some Scene {
        WindowGroup {
            WatchRecoveryView(store: workoutStore)
        }
    }
}
