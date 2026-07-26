import SwiftUI

struct WatchRecoveryView: View {
    @State private var showsDetails = false
    let store: WatchWorkoutStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    recoveryStatus
                    trainingSummary
                    syncStatus
                    workoutsLink
                    detailsButton
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("Recovery")
        }
        .tint(.orange)
    }

    private var recoveryStatus: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: store.recovery.systemImage)
                .font(.title2)
                .foregroundStyle(.orange)

            Text(store.recovery.headline)
                .font(.headline)

            Text(
                "\(store.recovery.locationName) · \(store.recovery.altitudeMeters) m"
            )
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(
                showsDetails
                    ? store.recovery.recommendation
                    : "Tap Recovery Advice for details."
            )
            .font(.caption)
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var syncStatus: some View {
        HStack(spacing: 4) {
            Image(
                systemName: store.lastUpdated == nil
                    ? "iphone.and.arrow.forward"
                    : "checkmark.icloud"
            )

            if let lastUpdated = store.lastUpdated {
                Text("Synced")
                Text(lastUpdated, style: .relative)
            } else {
                Text("Waiting for iPhone")
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
    }

    private var trainingSummary: some View {
        HStack {
            metric(value: "\(store.workouts.count)", label: "Workouts")
            Spacer()
            metric(value: longestHikeDuration, label: "Hike min")
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private var workoutsLink: some View {
        NavigationLink {
            WatchWorkoutsView(store: store)
        } label: {
            Label("View Workouts", systemImage: "list.bullet")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }

    private var longestHikeDuration: String {
        store.workouts
            .filter { $0.activity == "Hike" }
            .map(\.durationMinutes)
            .max()
            .map(String.init) ?? "—"
    }

    private var detailsButton: some View {
        Button(showsDetails ? "Show Less" : "Recovery Advice") {
            showsDetails.toggle()
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
    }

    private func metric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    WatchRecoveryView(
        store: WatchWorkoutStore(
            previewSnapshot: .preview
        )
    )
}
