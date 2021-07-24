import SwiftUI

@main
struct FramesApp: App {
    // let persistenceController = PersistenceController.shared
    @StateObject var model = Model()
    var body: some Scene {
        WindowGroup {
            Window(model: model)
                // .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
}
