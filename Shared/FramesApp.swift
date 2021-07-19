import SwiftUI

@main
struct FramesApp: App {
    let persistenceController = PersistenceController.shared
    @State var selection: Int = 0

    var body: some Scene {
        WindowGroup {
            // Window(model: Data())
            ScrollStack(
                direction: .horizontal,
                items: [0, 1, 2, 3, 4],
                size: 250,
                spacing: 20,
                selection: $selection
            )
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
