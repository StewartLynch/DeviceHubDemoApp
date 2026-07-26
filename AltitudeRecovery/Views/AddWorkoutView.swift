import SwiftUI

struct AddWorkoutView: View {
    let store: WorkoutStore
    @Environment(\.dismiss) private var dismiss

    @State private var activity = Activity.hike
    @State private var date = Date.now
    @State private var durationMinutes = 45
    @State private var distanceUnit = DistanceUnit.kilometres
    @State private var distanceValue = 5
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

                Section("Distance") {
                    Picker("Unit", selection: $distanceUnit) {
                        ForEach(DistanceUnit.allCases) { unit in
                            Text(unit.rawValue)
                                .tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)

                    Stepper(
                        "\(distanceValue) \(distanceUnit.abbreviation)",
                        value: $distanceValue,
                        in: distanceUnit.range,
                        step: distanceUnit.step
                    )
                }

                Stepper("Elevation: \(elevationGainMeters) metres", value: $elevationGainMeters, in: 0...3_000, step: 25)
            }
            .onChange(of: distanceUnit) { oldUnit, newUnit in
                distanceValue = newUnit.convert(
                    distanceValue,
                    from: oldUnit
                )
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
                distanceMeters: distanceUnit.meters(from: distanceValue),
                elevationGainMeters: elevationGainMeters
            )
        )
        dismiss()
    }
}

private enum DistanceUnit: String, CaseIterable, Identifiable {
    case kilometres = "Kilometres"
    case metres = "Metres"

    var id: Self { self }

    var abbreviation: String {
        switch self {
        case .kilometres: "km"
        case .metres: "m"
        }
    }

    var range: ClosedRange<Int> {
        switch self {
        case .kilometres: 1...200
        case .metres: 100...200_000
        }
    }

    var step: Int {
        switch self {
        case .kilometres: 1
        case .metres: 100
        }
    }

    func meters(from value: Int) -> Int {
        switch self {
        case .kilometres: value * 1_000
        case .metres: value
        }
    }

    func convert(_ value: Int, from oldUnit: Self) -> Int {
        let meters = oldUnit.meters(from: value)

        switch self {
        case .kilometres:
            return max(
                range.lowerBound,
                Int((Double(meters) / 1_000).rounded())
            )
        case .metres:
            return min(
                range.upperBound,
                max(range.lowerBound, meters)
            )
        }
    }
}
