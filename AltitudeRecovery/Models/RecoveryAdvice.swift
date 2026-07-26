import CoreLocation
import Foundation

struct RecoveryAdvice: Equatable {
    let locationName: String
    let altitudeMeters: Int
    let headline: String
    let recommendation: String
    let systemImage: String

    static let waiting = RecoveryAdvice(
        locationName: "Waiting for location",
        altitudeMeters: 0,
        headline: "Location needed",
        recommendation: "Allow location access, then use Device Hub to simulate a high-altitude location.",
        systemImage: "location"
    )

    static let noSimulatedLocation = RecoveryAdvice(
        locationName: "No simulated location",
        altitudeMeters: 0,
        headline: "Choose a Device Hub location",
        recommendation: "An iPhone simulator has no GPS position. Select a preset or custom location in Device Hub; None clears the simulated location.",
        systemImage: "location.slash"
    )

    static func make(
        location: CLLocation,
        resolvedLocationName: String? = nil
    ) -> RecoveryAdvice {
        let knownPlace = KnownPlace.nearest(to: location.coordinate)
        let altitude = knownPlace?.altitudeMeters
            ?? max(0, Int(location.altitude.rounded()))
        let place = knownPlace?.name
            ?? resolvedLocationName
            ?? "Selected Location"

        switch altitude {
        case 1_500...:
            return RecoveryAdvice(
                locationName: place,
                altitudeMeters: altitude,
                headline: "Prioritize altitude recovery",
                recommendation: "At this elevation, extend your recovery window, hydrate steadily, replace electrolytes, and keep tomorrow’s training easy until your breathing and sleep return to normal.",
                systemImage: "mountain.2.fill"
            )
        case 800..<1_500:
            return RecoveryAdvice(
                locationName: place,
                altitudeMeters: altitude,
                headline: "Give yourself extra time",
                recommendation: "Moderate elevation can increase the cost of a hard workout. Add hydration and choose a gentle session tomorrow.",
                systemImage: "mountain.2"
            )
        default:
            return RecoveryAdvice(
                locationName: place,
                altitudeMeters: altitude,
                headline: "Recovery looks on track",
                recommendation: "Your current elevation adds little extra strain. Rehydrate, refuel, and follow your normal recovery plan.",
                systemImage: "checkmark.circle.fill"
            )
        }
    }

    static func knownLocationName(
        for coordinate: CLLocationCoordinate2D
    ) -> String? {
        KnownPlace.nearest(to: coordinate)?.name
    }
}

private struct KnownPlace {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let altitudeMeters: Int

    static let all = [
        KnownPlace(
            name: "Berlin",
            coordinate: .init(latitude: 52.5200, longitude: 13.4050),
            altitudeMeters: 34
        ),
        KnownPlace(
            name: "Hong Kong",
            coordinate: .init(latitude: 22.3193, longitude: 114.1694),
            altitudeMeters: 30
        ),
        KnownPlace(
            name: "Honolulu",
            coordinate: .init(latitude: 21.3069, longitude: -157.8583),
            altitudeMeters: 5
        ),
        KnownPlace(
            name: "Johannesburg",
            coordinate: .init(latitude: -26.2041, longitude: 28.0473),
            altitudeMeters: 1_753
        ),
        KnownPlace(
            name: "London",
            coordinate: .init(latitude: 51.5074, longitude: -0.1278),
            altitudeMeters: 11
        ),
        KnownPlace(
            name: "Mexico City",
            coordinate: .init(latitude: 19.4326, longitude: -99.1332),
            altitudeMeters: 2_240
        ),
        KnownPlace(
            name: "Moscow",
            coordinate: .init(latitude: 55.7558, longitude: 37.6173),
            altitudeMeters: 156
        ),
        KnownPlace(
            name: "Mumbai",
            coordinate: .init(latitude: 19.0760, longitude: 72.8777),
            altitudeMeters: 14
        ),
        KnownPlace(
            name: "New York",
            coordinate: .init(latitude: 40.7128, longitude: -74.0060),
            altitudeMeters: 10
        ),
        KnownPlace(
            name: "Paris",
            coordinate: .init(latitude: 48.8566, longitude: 2.3522),
            altitudeMeters: 35
        ),
        KnownPlace(
            name: "Rio de Janeiro",
            coordinate: .init(latitude: -22.9068, longitude: -43.1729),
            altitudeMeters: 5
        ),
        KnownPlace(
            name: "San Francisco",
            coordinate: .init(latitude: 37.7749, longitude: -122.4194),
            altitudeMeters: 16
        ),
        KnownPlace(
            name: "Sydney",
            coordinate: .init(latitude: -33.8688, longitude: 151.2093),
            altitudeMeters: 58
        ),
        KnownPlace(
            name: "Tokyo",
            coordinate: .init(latitude: 35.6762, longitude: 139.6503),
            altitudeMeters: 40
        ),
        KnownPlace(
            name: "Warsaw",
            coordinate: .init(latitude: 52.2297, longitude: 21.0122),
            altitudeMeters: 100
        ),
        KnownPlace(
            name: "Cupertino",
            coordinate: .init(latitude: 37.3317, longitude: -122.0307),
            altitudeMeters: 56
        ),
        KnownPlace(
            name: "Vancouver",
            coordinate: .init(latitude: 49.2827, longitude: -123.1207),
            altitudeMeters: 70
        ),
        KnownPlace(
            name: "Banff",
            coordinate: .init(latitude: 51.1784, longitude: -115.5708),
            altitudeMeters: 1_383
        ),
        KnownPlace(
            name: "Denver",
            coordinate: .init(latitude: 39.7392, longitude: -104.9903),
            altitudeMeters: 1_609
        ),
    ]

    static func nearest(to coordinate: CLLocationCoordinate2D) -> KnownPlace? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let match = all.min { lhs, rhs in
            location.distance(from: lhs.location) < location.distance(from: rhs.location)
        }

        guard let match, location.distance(from: match.location) < 100_000 else {
            return nil
        }
        return match
    }

    private var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
