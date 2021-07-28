import SwiftUI

@main
struct FramesApp: App {
    @StateObject var model = Model()
    var body: some Scene {
        WindowGroup {
            Window(model: model)
        }
    }
    
}
