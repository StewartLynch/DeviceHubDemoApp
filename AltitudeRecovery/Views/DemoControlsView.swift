import SwiftUI

struct DemoControlsView: View {
    let model: AppModel
    @State private var showsResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Sample Data") {
                    LabeledContent("Saved workouts", value: "\(model.workouts.workouts.count)")

                    Button("Reset Sample Data", systemImage: "arrow.counterclockwise") {
                        showsResetConfirmation = true
                    }

                    Button("Clear All Workouts", systemImage: "trash", role: .destructive) {
                        model.workouts.clear()
                    }
                }

                Section {
                    LabeledContent(
                        "Detected place",
                        value: model.location.advice.locationName
                    )
                    LabeledContent(
                        "Altitude",
                        value: "\(model.location.advice.altitudeMeters) m"
                    )

                    LabeledContent(
                        "Recovery mode",
                        value: model.location.advice.headline
                    )

                    if let errorMessage = model.location.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Device Hub Location")
                } footer: {
                    Text(
                        "In Device Hub, select this iPhone and change Location. "
                            + "These values, the Today card, and the paired Watch "
                            + "update when Core Location reports the new position."
                    )
                }
            }
            .navigationTitle("Demo Controls")
            .confirmationDialog(
                "Reset sample data?",
                isPresented: $showsResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Confirm Reset", action: model.resetSampleData)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This restores the four sample workouts.")
            }
        }
    }
}
