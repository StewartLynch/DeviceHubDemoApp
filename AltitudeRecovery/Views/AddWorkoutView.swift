import SwiftUI

struct AddWorkoutView: View {
    let store: WorkoutStore
    @Environment(\.dismiss) private var dismiss

    @State private var activity = Activity.hike
    @State private var date = Date.now
    @State private var durationMinutes = 45
    @State private var elevationGainMeters = 250

    var body: some View {
        NavigationStack {
            Form {
                Picker("Activity", selection: $activity) {
                    ForEach(Activity.allCases) { activity in
                        Label(activity.rawValue, systemImage: activity.symbolName)
                            .tag(activity)
                    }
                }

                DatePicker("Date", selection: $date, in: ...Date.now)

                Stepper("Duration: \(durationMinutes) minutes", value: $durationMinutes, in: 5...300, step: 5)
                Stepper("Elevation: \(elevationGainMeters) metres", value: $elevationGainMeters, in: 0...3_000, step: 25)
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: addWorkout)
                        .bold()
                }
            }
        }
    }

    private func addWorkout() {
        store.add(
            Workout(
                date: date,
                activity: activity,
                durationMinutes: durationMinutes,
                elevationGainMeters: elevationGainMeters
            )
        )
        dismiss()
    }
}

