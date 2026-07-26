import SwiftUI

struct WatchWorkoutsView: View {
    let store: WatchWorkoutStore

    var body: some View {
        Group {
            if store.workouts.isEmpty {
                ContentUnavailableView(
                    "No Workouts",
                    systemImage: "iphone.and.arrow.forward",
                    description: Text("Open the iPhone app to sync workouts.")
                )
            } else {
                List(store.workouts) { workout in
                    NavigationLink {
                        WatchWorkoutDetailView(workout: workout)
                    } label: {
                        WatchWorkoutRow(workout: workout)
                    }
                }
            }
        }
        .navigationTitle("Workouts")
    }
}

private struct WatchWorkoutRow: View {
    let workout: WorkoutTransfer

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: workout.symbolName)
                .foregroundStyle(.orange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(workout.activity)
                    .font(.headline)
                Text("\(workout.durationMinutes) min · \(workout.elevationGainMeters) m")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct WatchWorkoutDetailView: View {
    let workout: WorkoutTransfer

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: workout.symbolName)
                    .font(.largeTitle)
                    .foregroundStyle(.orange)

                Text(workout.activity)
                    .font(.title3.bold())

                detailRow(
                    title: "Duration",
                    value: "\(workout.durationMinutes) minutes"
                )
                detailRow(
                    title: "Elevation",
                    value: "\(workout.elevationGainMeters) metres"
                )
                detailRow(
                    title: "Date",
                    value: workout.date.formatted(
                        .dateTime.weekday(.abbreviated).month(.abbreviated).day()
                    )
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Details")
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        WatchWorkoutsView(
            store: WatchWorkoutStore(
                previewSnapshot: .preview
            )
        )
    }
}
