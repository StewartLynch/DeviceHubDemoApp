# Altitude Recovery

Altitude Recovery is a small SwiftUI app built for demonstrating Device Hub and `devicectl` workflows.

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

The project targets iOS 18 or later. It can be built with Xcode 26 and is intended to be recorded using Xcode 27 and Device Hub.

## Device Hub configuration demonstration

1. Open **Demo**, choose **Reset Sample Data**, and tap **Confirm Reset**.
2. In Device Hub, simulate Johannesburg.
3. Return to **Demo** and confirm **Johannesburg ready** and an altitude of **1753 m**.
4. Return to **Today** and observe the longer high-altitude recommendation.
5. Rotate between portrait and landscape, change appearance, and increase text size.
6. Open the same app on a second device size and compare the layouts side by side.

The recommendation remains fully readable at every text size. The point of this sequence is to demonstrate how quickly Device Hub can mirror and compare configurations.

## App-container demonstration

Add or delete workouts, then use Device Hub's Apps inspector to download the app data container. Clear the workouts or install the app on another simulator, replace its container, and relaunch. The transferred workouts should appear.

## Suggested location

Johannesburg coordinates are approximately:

```text
Latitude:  -26.2041
Longitude:  28.0473
```

The app identifies locations near Johannesburg, Vancouver, Banff, Denver, and Mexico City. Device Hub may simulate coordinates without a meaningful altitude, so the app uses a known elevation for those five cities. Other locations display a coordinate-based label and use Core Location's altitude value.
