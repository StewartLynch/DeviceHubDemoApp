# Altitude Recovery

Altitude Recovery is a small SwiftUI app built for demonstrating Device Hub and `devicectl` workflows.

The project also includes an **AltitudeRecovery Watch App** target. The iPhone app sends an app snapshot through WatchConnectivity containing both its current workout list and its location-derived recovery advice. The Watch caches the latest snapshot. From the recovery summary, you can see the same detected place and altitude, then open the synchronized workouts and drill into duration, elevation gain, and date details.

## What the app demonstrates

- Persistent workout data stored in the app's Application Support container
- Adding, deleting, resetting, exporting, and restoring meaningful app state
- Live Core Location updates, including simulated locations and altitude
- Location-sensitive recovery advice that changes for Johannesburg and other known cities
- Responsive portrait and landscape layouts
- Light and dark appearance, Dynamic Type, rotation, and multi-device comparison

## Open and run

1. Open `AltitudeRecovery.xcodeproj` in Xcode.
2. Select the `AltitudeRecovery` scheme and an iPhone simulator.
3. Build and run.
4. Tap **Allow While Using App** when location permission is requested.

To run the watch app, use a paired iPhone and Apple Watch simulator:

1. Run the **AltitudeRecovery** scheme on the paired iPhone simulator.
2. Run the **AltitudeRecovery Watch App** scheme on its Watch simulator.
3. Bring the iPhone app to the foreground once. Its current app snapshot is sent to the Watch.
4. Add, delete, reset, or restore workouts—or change the iPhone's simulated location—in Device Hub. The Watch receives the newest snapshot and keeps a local cached copy for offline viewing.

If Xcode reports that the matching watchOS platform is not installed, open **Xcode → Settings → Components** and install the watchOS component before running either scheme. The iPhone scheme embeds the Watch app as its companion.

The project targets iOS 18 or later. It can be built with Xcode 26 and is intended to be recorded using Xcode 27 and Device Hub.

## Device Hub configuration demonstration

1. Open **Demo**, choose **Reset Sample Data**, and tap **Confirm Reset**.
2. On the iPhone, note the detected place and altitude in **Demo → Device Hub Location** and on the **Today → Device Hub Location** card.
3. In Device Hub, select that iPhone and simulate Johannesburg.
4. Return to **Demo** and confirm that the place changes to **Johannesburg**, the altitude changes to **1753 m**, and the recovery mode changes to **High Altitude**.
5. Return to **Today** and observe the longer high-altitude recommendation.
6. Open the Watch app. Its recovery screen should also show **Johannesburg · 1753 m** after the latest snapshot arrives from the iPhone.
7. Rotate between portrait and landscape, change appearance, and increase text size.
8. Open the same app on a second device size and compare the layouts side by side.

The recommendation remains fully readable at every text size. The point of this sequence is to demonstrate how quickly Device Hub can mirror and compare configurations.

Device Hub changes the iPhone's simulated Core Location position; it does not directly configure the Watch app. The running iPhone app converts the Core Location update into recovery advice and sends that result to its paired Watch through WatchConnectivity. Keep the iPhone app running or bring it back to the foreground after changing the location, then allow a moment for the Watch's **Synced** status and recovery values to refresh.

## App-container demonstration

Add or delete workouts, then use Device Hub's Apps inspector to download the app data container. Clear the workouts or install the app on another simulator, replace its container, and relaunch. The transferred workouts should appear.

After replacing and relaunching the iPhone container, the restored workout list is also sent to the paired Watch app.

## Suggested location

Johannesburg coordinates are approximately:

```text
Latitude:  -26.2041
Longitude:  28.0473
```

The app identifies locations near Johannesburg, Vancouver, Banff, Denver, and Mexico City and uses known elevations for those five cities. Other simulated positions are reverse geocoded and displayed as a city and region rather than raw coordinates; their altitude comes from Core Location.
