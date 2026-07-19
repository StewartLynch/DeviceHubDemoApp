import SwiftUI

@main
struct AltitudeRecoveryApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
        }
    }
}

