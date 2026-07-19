import SwiftUI

struct WorkoutsView: View {
    let store: WorkoutStore
    @State private var showsAddWorkout = false

    var body: some View {
        NavigationStack {
            List {
                if store.workouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts",
                        systemImage: "figure.run",
                        description: Text("Add a workout or restore the sample data from the Demo tab.")
                    )
                } else {
                    ForEach(store.workouts) { workout in
                        WorkoutRow(workout: workout)
                    }
                    .onDelete(perform: deleteWorkouts)
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Workout", systemImage: "plus") {
                        showsAddWorkout = true
                    }
                }
            }
            .sheet(isPresented: $showsAddWorkout) {
                AddWorkoutView(store: store)
            }
        }
    }

    private func deleteWorkouts(at offsets: IndexSet) {
        let ids = Set(offsets.map { store.workouts[$0].id })
        store.delete(ids: ids)
    }
}

private struct WorkoutRow: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: workout.activity.symbolName)
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(workout.activity.rawValue)
                    .font(.headline)
                Text(workout.date, format: .dateTime.weekday(.abbreviated).month().day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(workout.durationMinutes) min")
                Text("↗ \(workout.elevationGainMeters) m")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline.monospacedDigit())
        }
        .accessibilityElement(children: .combine)
    }
}

