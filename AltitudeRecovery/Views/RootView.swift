import SwiftUI

struct RootView: View {
    let model: AppModel
    @Environment(\.scenePhase) private var scenePhase

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
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                model.location.refresh()
            }
        }
    }
}

#Preview {
    RootView(model: AppModel())
}
