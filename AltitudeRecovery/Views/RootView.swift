import SwiftUI

struct RootView: View {
    let model: AppModel

    var body: some View {
        TabView {
            Tab("Today", systemImage: "sun.max.fill") {
                DashboardView(model: model)
            }

            Tab("Workouts", systemImage: "figure.run") {
                WorkoutsView(store: model.workouts)
            }

            Tab("Demo", systemImage: "wrench.and.screwdriver.fill") {
                DemoControlsView(model: model)
            }
        }
        .tint(.indigo)
        .task {
            model.location.start()
        }
    }
}

#Preview {
    RootView(model: AppModel())
}
