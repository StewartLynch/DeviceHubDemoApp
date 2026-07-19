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

                Section("Location") {
                    LabeledContent("Current place", value: model.location.advice.locationName)
                    LabeledContent("Altitude", value: "\(model.location.advice.altitudeMeters) m")

                    Label(
                        isJohannesburgReady ? "Johannesburg ready" : "Johannesburg not active",
                        systemImage: isJohannesburgReady
                            ? "checkmark.circle.fill"
                            : "location.circle"
                    )
                    .foregroundStyle(isJohannesburgReady ? .green : .orange)

                    if let error = model.location.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    } else {
                        Text("Use Device Hub to simulate Johannesburg, then return to Today.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Device Hub Checklist") {
                    RecipeStep(number: 1, text: "Simulate Johannesburg")
                    RecipeStep(number: 2, text: "Try portrait and landscape")
                    RecipeStep(number: 3, text: "Change appearance")
                    RecipeStep(number: 4, text: "Change text size")
                    RecipeStep(number: 5, text: "Compare another device")
                }
            }
            .navigationTitle("Demo Controls")
            .confirmationDialog(
                "Reset the Device Hub demo?",
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

    private var isJohannesburgReady: Bool {
        model.location.advice.locationName == "Johannesburg"
            && model.location.advice.altitudeMeters >= 1_500
    }
}

private struct RecipeStep: View {
    let number: Int
    let text: String

    var body: some View {
        Label {
            Text(text)
        } icon: {
            Text("\(number)")
                .font(.caption.bold())
                .frame(width: 24, height: 24)
                .background(.indigo.opacity(0.15), in: Circle())
                .foregroundStyle(.indigo)
        }
        .accessibilityElement(children: .combine)
    }
}
