import SwiftUI
import CoreData

struct Window: View {
    
    @ObservedObject var model: Model
    @Environment(\.colorScheme) var colorscheme
    
    /*
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Form.timestamp, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<Form>
    */

    var body: some View {
        NavigationView {
            Editor(model: model)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if model.data.isEditing {
                            Button(action: {
                                withAnimation {
                                    model.data.isEditing.toggle()
                                }
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                            }
                        } else {
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
                    }
                    ToolbarItem(placement: .principal) {
                        Text(UIDevice.current.userInterfaceIdiom == .pad ? "Augmented Frames" : "Frames")
                            .bold()
                            .onTapGesture {
                                model.data.welcome.toggle()
                            }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            model.data.isAugmenting.toggle()
                        }) {
                            Text("AR")
                        }
                        .disabled(!model.data.isEditing)
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $model.data.welcome) {
            Welcome(model: model)
                .modifier(DisableModalDismiss(disabled: true))
        }
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model, type: "import")
        }
        .sheet(isPresented: $model.data.isCapturing) {
            ImagePicker(model: model, type: "capture")
        }
        .fullScreenCover(isPresented: $model.data.isAugmenting) {
            Augment(model: model)
        }
        .onAppear {
            model.data.colorscheme = colorscheme
        }
        .onChange(of: colorscheme) { value in
            withAnimation {
                model.data.colorscheme = value
            }
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

    /*
    private func addItem() {
        withAnimation {
            let newItem = Form(context: viewContext)
            // newItem.timestamp = Date()

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
    */
}

/*
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
} ()
*/

// source: https://stackoverflow.com/a/60939207/15072454

extension UIApplication {
    func visibleViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return nil }
        guard let rootViewController = window.rootViewController else { return nil }
        return UIApplication.getVisibleViewControllerFrom(vc: rootViewController)
    }
    private static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return UIApplication.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return UIApplication.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIApplication.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

struct DisableModalDismiss: ViewModifier {
    let disabled: Bool
    func body(content: Content) -> some View {
        disableModalDismiss()
        return AnyView(content)
    }
    func disableModalDismiss() {
        guard let visibleController = UIApplication.shared.visibleViewController() else { return }
        visibleController.isModalInPresentation = disabled
    }
}

struct Window_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
