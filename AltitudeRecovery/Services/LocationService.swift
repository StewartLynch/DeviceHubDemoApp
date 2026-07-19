@preconcurrency import CoreLocation
import Observation

@Observable
@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    private(set) var currentLocation: CLLocation?
    private(set) var authorizationStatus: CLAuthorizationStatus
    private(set) var errorMessage: String?

    @ObservationIgnored private let manager = CLLocationManager()

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    var advice: RecoveryAdvice {
        currentLocation.map(RecoveryAdvice.make(location:)) ?? .waiting
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
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError = error as? CLError
        guard locationError?.code != .locationUnknown else { return }
        errorMessage = error.localizedDescription
    }
}

