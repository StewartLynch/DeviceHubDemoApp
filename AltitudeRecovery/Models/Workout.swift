import Foundation

struct Workout: Codable, Hashable, Identifiable {
    let id: UUID
    var date: Date
    var activity: Activity
    var durationMinutes: Int
    var elevationGainMeters: Int

    init(
        id: UUID = UUID(),
        date: Date,
        activity: Activity,
        durationMinutes: Int,
        elevationGainMeters: Int
    ) {
        self.id = id
        self.date = date
        self.activity = activity
        self.durationMinutes = durationMinutes
        self.elevationGainMeters = elevationGainMeters
    }
}

enum Activity: String, Codable, CaseIterable, Hashable, Identifiable {
    case hike = "Hike"
    case run = "Run"
    case cycle = "Cycle"
    case walk = "Walk"

    var id: Self { self }

    var symbolName: String {
        switch self {
        case .hike: "figure.hiking"
        case .run: "figure.run"
        case .cycle: "figure.outdoor.cycle"
        case .walk: "figure.walk"
        }
    }

    var tintName: String {
        switch self {
        case .hike: "green"
        case .run: "orange"
        case .cycle: "blue"
        case .walk: "purple"
        }
    }
}

extension Workout {
    static func samples(relativeTo now: Date = .now) -> [Workout] {
        let calendar = Calendar.current

        return [
            Workout(
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                activity: .hike,
                durationMinutes: 94,
                elevationGainMeters: 620
            ),
            Workout(
                date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                activity: .run,
                durationMinutes: 42,
                elevationGainMeters: 180
            ),
            Workout(
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                activity: .cycle,
                durationMinutes: 76,
                elevationGainMeters: 410
            ),
            Workout(
                date: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
                activity: .walk,
                durationMinutes: 31,
                elevationGainMeters: 55
            ),
        ]
    }
}

