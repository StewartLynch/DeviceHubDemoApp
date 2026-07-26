import Foundation

struct WorkoutTransfer: Codable, Hashable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let activity: String
    let durationMinutes: Int
    let elevationGainMeters: Int

    var symbolName: String {
        switch activity {
        case "Hike": "figure.hiking"
        case "Run": "figure.run"
        case "Cycle": "figure.outdoor.cycle"
        default: "figure.walk"
        }
    }
}

extension WorkoutTransfer {
    static let previewSamples: [WorkoutTransfer] = {
        let calendar = Calendar.current
        let now = Date.now

        return [
            WorkoutTransfer(
                id: UUID(),
                date: now,
                activity: "Hike",
                durationMinutes: 135,
                elevationGainMeters: 900
            ),
            WorkoutTransfer(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                activity: "Hike",
                durationMinutes: 94,
                elevationGainMeters: 620
            ),
            WorkoutTransfer(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                activity: "Run",
                durationMinutes: 42,
                elevationGainMeters: 180
            ),
            WorkoutTransfer(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                activity: "Cycle",
                durationMinutes: 76,
                elevationGainMeters: 410
            ),
            WorkoutTransfer(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
                activity: "Walk",
                durationMinutes: 31,
                elevationGainMeters: 55
            ),
        ]
    }()
}
