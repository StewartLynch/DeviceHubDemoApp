import Foundation

struct AppSnapshotTransfer: Codable, Sendable {
    let workouts: [WorkoutTransfer]
    let recovery: RecoveryTransfer
}

struct RecoveryTransfer: Codable, Sendable {
    let locationName: String
    let altitudeMeters: Int
    let headline: String
    let recommendation: String
    let systemImage: String

    static let waiting = RecoveryTransfer(
        locationName: "Waiting for iPhone",
        altitudeMeters: 0,
        headline: "Location needed",
        recommendation: "Open the iPhone app, then change its location in Device Hub.",
        systemImage: "iphone.and.arrow.forward"
    )
}

extension AppSnapshotTransfer {
    static let preview = AppSnapshotTransfer(
        workouts: WorkoutTransfer.previewSamples,
        recovery: RecoveryTransfer(
            locationName: "Johannesburg",
            altitudeMeters: 1_753,
            headline: "Prioritize altitude recovery",
            recommendation: "Hydrate steadily and keep tomorrow's training easy.",
            systemImage: "mountain.2.fill"
        )
    )
}
