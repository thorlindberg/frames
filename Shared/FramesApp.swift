import SwiftUI

@main
struct FramesApp: App {
    @StateObject var model = Model()
    var body: some Scene {
        WindowGroup {
            RootView {
                Window(model: model)
                    .statusBarStyle(.lightContent)
                    .preferredColorScheme(.dark)
            }
        }
    }
    
}
