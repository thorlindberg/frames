import SwiftUI
import CoreData

struct Window: View {
    
    @ObservedObject var model: Data
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            Editor(model: model)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Button(action: {
                            model.data.welcome.toggle()
                        }) {
                            Text(model.data.isEditing ? "Edit frame" : "Augmented Frames")
                                .bold()
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        if model.data.isEditing {
                            Button(action: {
                                withAnimation {
                                    model.data.isEditing.toggle()
                                }
                            }) {
                                Text("Close")
                            }
                        } else {
                            Menu {
                                Button(action: {
                                    model.data.isImporting.toggle()
                                }) {
                                    Label("Import from Photos", systemImage: "photo")
                                }
                                Button(action: {
                                    //
                                }) {
                                    Label("Capture with Camera", systemImage: "camera")
                                }
                                Button(action: {
                                    UIApplication.shared.windows.filter({$0.isKeyWindow})
                                        .first?.rootViewController?
                                        .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                                }) {
                                    Label("Scan with Camera", systemImage: "viewfinder")
                                }
                            } label: {
                                Image(systemName: "camera.fill")
                            }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if !model.data.isEditing {
                            Button(action: {
                                model.data.isAugmenting.toggle()
                            }) {
                                Text("AR")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // disables split view on iPad
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model)
        }
        .sheet(isPresented: $model.data.welcome) {
            Welcome(model: model)
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
