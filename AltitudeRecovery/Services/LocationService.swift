@preconcurrency import CoreLocation
import Observation

@Observable
@MainActor
final class LocationService: NSObject, @preconcurrency CLLocationManagerDelegate {
    private(set) var currentLocation: CLLocation?
    private(set) var authorizationStatus: CLAuthorizationStatus
    private(set) var errorMessage: String?
    private(set) var resolvedLocationName: String?

    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private let geocoder = CLGeocoder()
    @ObservationIgnored private var geocodingTask: Task<Void, Never>?
    @ObservationIgnored private var lastGeocodedLocation: CLLocation?
    @ObservationIgnored var onLocationChanged: ((CLLocation?) -> Void)?

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    var advice: RecoveryAdvice {
        guard let currentLocation else { return .waiting }
        return RecoveryAdvice.make(
            location: currentLocation,
            resolvedLocationName: resolvedLocationName
        )
    }

    func start() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "Location access is off. Enable it in Settings to use Device Hub location simulation."
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        errorMessage = nil
        updateLocationName(for: location)
        onLocationChanged?(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError = error as? CLError
        guard locationError?.code != .locationUnknown else { return }
        errorMessage = error.localizedDescription
    }

    private func updateLocationName(for location: CLLocation) {
        if let knownName = RecoveryAdvice.knownLocationName(
            for: location.coordinate
        ) {
            resolvedLocationName = knownName
            lastGeocodedLocation = location
            return
        }

        if let lastGeocodedLocation,
           location.distance(from: lastGeocodedLocation) < 1_000,
           resolvedLocationName != nil {
            return
        }

        resolvedLocationName = nil
        geocodingTask?.cancel()
        geocoder.cancelGeocode()

        geocodingTask = Task { [weak self] in
            guard let self else { return }

            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                guard !Task.isCancelled,
                      let currentLocation,
                      currentLocation.distance(from: location) < 1_000
                else {
                    return
                }

                resolvedLocationName = Self.displayName(
                    for: placemarks.first
                )
                lastGeocodedLocation = location
                onLocationChanged?(location)
            } catch {
                guard !Task.isCancelled else { return }
                resolvedLocationName = "Current Location"
                lastGeocodedLocation = location
                onLocationChanged?(location)
            }
        }
    }

    private static func displayName(for placemark: CLPlacemark?) -> String {
        guard let placemark else { return "Current Location" }

        let city = placemark.locality
            ?? placemark.subLocality
            ?? placemark.subAdministrativeArea
        let region = placemark.administrativeArea
        let country = placemark.country

        if let city, let region, city != region {
            return "\(city), \(region)"
        }
        return city ?? region ?? country ?? "Current Location"
    }
}
