import SwiftUI

@main
struct FramesApp: App {
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Window(model: Data())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
}
