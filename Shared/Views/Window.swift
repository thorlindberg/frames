import SwiftUI
import CoreData

struct Window: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            ZStack {
                if model.data.reload {
                    Browse(model: model)
                } else {
                    Browse(model: model)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        model.data.welcome.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            model.data.isEditing = false
                        }
                    }) {
                        Text("Augmented Frames")
                            .bold()
                    }
                    .accentColor(colorscheme == .dark ? .white : .black)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Menu {
                        Button(action: {
                            model.data.isImporting.toggle()
                        }) {
                            Label("Choose Photo", systemImage: "photo")
                        }
                        Button(action: {
                            model.data.isCapturing.toggle()
                        }) {
                            Label("Capture Photo", systemImage: "camera")
                        }
                        Button(action: {
                            UIApplication.shared.windows.filter({$0.isKeyWindow})
                                .first?.rootViewController?
                                .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                        }) {
                            Label("Scan Photo", systemImage: "viewfinder")
                        }
                    } label: {
                        Image(systemName: "camera.fill")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        model.data.isAugmenting.toggle()
                    }) {
                        Text("AR")
                    }
                }
                /*
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Button(action: {
                            model.data.isEditing.toggle()
                        }) {
                            Text("Customize")
                        }
                        Spacer()
                    }
                }
                */
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // disables split view on iPad
        .sheet(isPresented: $model.data.welcome) {
            Welcome(model: model)
                .modifier(DisableModalDismiss(disabled: true))
        }
        .sheet(isPresented: $model.data.isEditing) {
            Editor(model: model)
                .modifier(DisableModalDismiss(disabled: true))
        }
        .fullScreenCover(isPresented: $model.data.isImporting) {
            ImagePicker(model: model, type: "import")
                .modifier(DisableModalDismiss(disabled: true))
        }
        .fullScreenCover(isPresented: $model.data.isCapturing) {
            ImagePicker(model: model, type: "capture")
                .modifier(DisableModalDismiss(disabled: true))
        }
        .fullScreenCover(isPresented: $model.data.isAugmenting) {
            Augment(model: model)
        }
        /*
        List {
            ForEach(items) { item in
                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            #if os(iOS)
            EditButton()
            #endif

            Button(action: addItem) {
                Label("Add Item", systemImage: "plus")
            }
        }
        */
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct Window_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
