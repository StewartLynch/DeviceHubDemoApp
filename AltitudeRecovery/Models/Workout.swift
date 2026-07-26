import Foundation

struct Workout: Codable, Hashable, Identifiable {
    let id: UUID
    var date: Date
    var activity: Activity
    var durationMinutes: Int
    var distanceMeters: Int
    var elevationGainMeters: Int

    init(
        id: UUID = UUID(),
        date: Date,
        activity: Activity,
        durationMinutes: Int,
        distanceMeters: Int = 0,
        elevationGainMeters: Int
    ) {
        self.id = id
        self.date = date
        self.activity = activity
        self.durationMinutes = durationMinutes
        self.distanceMeters = distanceMeters
        self.elevationGainMeters = elevationGainMeters
    }

    var formattedDistance: String {
        if distanceMeters >= 1_000 {
            let kilometres = Double(distanceMeters) / 1_000
            return kilometres.formatted(
                .number.precision(.fractionLength(
                    kilometres.rounded() == kilometres ? 0 : 1
                ))
            ) + " km"
        }
        return "\(distanceMeters) m"
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case activity
        case durationMinutes
        case distanceMeters
        case elevationGainMeters
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        activity = try container.decode(Activity.self, forKey: .activity)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        distanceMeters = try container.decodeIfPresent(
            Int.self,
            forKey: .distanceMeters
        ) ?? 0
        elevationGainMeters = try container.decode(
            Int.self,
            forKey: .elevationGainMeters
        )
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
                distanceMeters: 12_400,
                elevationGainMeters: 620
            ),
            Workout(
                date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                activity: .run,
                durationMinutes: 42,
                distanceMeters: 8_000,
                elevationGainMeters: 180
            ),
            Workout(
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                activity: .cycle,
                durationMinutes: 76,
                distanceMeters: 32_000,
                elevationGainMeters: 410
            ),
            Workout(
                date: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
                activity: .walk,
                durationMinutes: 31,
                distanceMeters: 3_200,
                elevationGainMeters: 55
            ),
        ]
    }
}
