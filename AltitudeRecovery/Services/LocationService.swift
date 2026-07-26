@preconcurrency import CoreLocation
import Observation

@Observable
@MainActor
final class LocationService: NSObject, @preconcurrency CLLocationManagerDelegate {
    enum Source: Equatable {
        case unavailable
        case deviceHub
        case deviceGPS

        var title: String {
            switch self {
            case .deviceHub:
                "Device Hub Location"
            case .deviceGPS:
                "Current Location"
            case .unavailable:
#if targetEnvironment(simulator)
                "Device Hub Location"
#else
                "Current Location"
#endif
            }
        }

        var guidance: String {
            switch self {
            case .deviceHub:
                "Change Location in Device Hub to update this card"
            case .deviceGPS:
                "Using this iPhone’s current GPS location"
            case .unavailable:
#if targetEnvironment(simulator)
                "Select a location in Device Hub to update this card"
#else
                "Waiting for this iPhone’s current GPS location"
#endif
            }
        }

        var guidanceSystemImage: String {
            switch self {
            case .deviceHub:
                "location.fill.viewfinder"
            case .deviceGPS:
                "location.fill"
            case .unavailable:
                "location.slash"
            }
        }
    }

    private(set) var currentLocation: CLLocation?
    private(set) var authorizationStatus: CLAuthorizationStatus
    private(set) var errorMessage: String?
    private(set) var resolvedLocationName: String?

    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private let geocoder = CLGeocoder()
    @ObservationIgnored private var geocodingTask: Task<Void, Never>?
    @ObservationIgnored private var lastGeocodedLocation: CLLocation?
    @ObservationIgnored var onLocationChanged: ((CLLocation?) -> Void)?
#if targetEnvironment(simulator)
    @ObservationIgnored private var simulatorProbeTask: Task<Void, Never>?
    @ObservationIgnored private var simulatorRequestStartedAt: Date?
#endif

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    var advice: RecoveryAdvice {
        guard let currentLocation else {
#if targetEnvironment(simulator)
            return .noSimulatedLocation
#else
            return .waiting
#endif
        }
        return RecoveryAdvice.make(
            location: currentLocation,
            resolvedLocationName: resolvedLocationName
        )
    }

    var source: Source {
        guard let currentLocation else { return .unavailable }

#if targetEnvironment(simulator)
        return .deviceHub
#else
        if currentLocation.sourceInformation?.isSimulatedBySoftware == true {
            return .deviceHub
        }
        return .deviceGPS
#endif
    }

    var sourceDescription: String {
        switch source {
        case .unavailable:
#if targetEnvironment(simulator)
            return "No simulated location"
#else
            return "Waiting for device GPS"
#endif
        case .deviceHub:
            return "Device Hub simulation"
        case .deviceGPS:
            return "Device GPS"
        }
    }

    func start() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        case .denied, .restricted:
            errorMessage = "Location access is off. Enable it in Settings to use Device Hub location simulation."
        @unknown default:
            break
        }
    }

    func refresh() {
        guard authorizationStatus == .authorizedAlways
                || authorizationStatus == .authorizedWhenInUse
        else {
            start()
            return
        }

#if !targetEnvironment(simulator)
        if currentLocation?.sourceInformation?.isSimulatedBySoftware == true {
            clearLocation()
        }

        manager.stopUpdatingLocation()
        manager.startUpdatingLocation()
#endif
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            startLocationUpdates()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

#if targetEnvironment(simulator)
        guard let simulatorRequestStartedAt,
              location.timestamp >= simulatorRequestStartedAt.addingTimeInterval(-0.5)
        else {
            clearLocation()
            return
        }
#endif

        receive(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError = error as? CLError

        if locationError?.code == .locationUnknown {
            if currentLocation?.sourceInformation?.isSimulatedBySoftware == true {
                clearLocation()
            }
            return
        }

        errorMessage = error.localizedDescription
    }

    private func receive(_ location: CLLocation) {
        let isMeaningfulChange = isMeaningfulChange(to: location)
        currentLocation = location
        errorMessage = nil
        updateLocationName(for: location)
        if isMeaningfulChange {
            onLocationChanged?(location)
        }
    }

    private func startLocationUpdates() {
#if targetEnvironment(simulator)
        startSimulatorProbes()
#else
        manager.startUpdatingLocation()
#endif
    }

#if targetEnvironment(simulator)
    private func startSimulatorProbes() {
        guard simulatorProbeTask == nil else { return }

        simulatorProbeTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }

                simulatorRequestStartedAt = Date()
                manager.requestLocation()

                do {
                    try await Task.sleep(for: .seconds(2))
                } catch {
                    return
                }
            }
        }
    }
#endif

    private func clearLocation() {
        guard currentLocation != nil
                || resolvedLocationName != nil
                || lastGeocodedLocation != nil
        else {
            return
        }

        geocodingTask?.cancel()
        geocoder.cancelGeocode()
        currentLocation = nil
        resolvedLocationName = nil
        lastGeocodedLocation = nil
        onLocationChanged?(nil)
    }

    private func isMeaningfulChange(to location: CLLocation) -> Bool {
        guard let currentLocation else { return true }

        let sourceChanged =
            currentLocation.sourceInformation?.isSimulatedBySoftware
            != location.sourceInformation?.isSimulatedBySoftware
        let altitudeChanged =
            abs(currentLocation.altitude - location.altitude) >= 1
        let positionChanged =
            currentLocation.distance(from: location) >= 1

        return sourceChanged || altitudeChanged || positionChanged
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
