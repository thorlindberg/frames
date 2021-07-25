import SwiftUI
import CoreData

struct Window: View {
    
    @ObservedObject var model: Model
    @Environment(\.colorScheme) var colorscheme
    @Namespace private var animation
    
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
            ZStack {
                if model.data.isFocused != -1 {
                    Image(uiImage: model.data.frames[model.data.isFocused].framed)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: model.data.isFocused, in: animation)
                        .padding()
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 3), spacing: 0) {
                                Button(action: {
                                    model.data.isCreating.toggle()
                                    model.data.isEditing.toggle()
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(colorscheme == .dark ? .black : .white)
                                        Image(systemName: "plus")
                                            .font(.system(size: geometry.size.width / 15))
                                    }
                                    .frame(height: geometry.size.width / 3)
                                }
                                ForEach(0...max(model.data.frames.count, Int(geometry.size.height / 55)), id: \.self) { index in
                                    if index < model.data.frames.count {
                                        Button(action: {
                                            withAnimation {
                                                model.data.isFocused = index
                                            }
                                        }) {
                                            ZStack {
                                                Rectangle()
                                                    .foregroundColor(colorscheme == .dark ? .white : .black)
                                                    .opacity(index % 2 != 0 ? 0 : colorscheme == .dark ? 0.07 : 0.03)
                                                Image(uiImage: model.data.frames[index].framed)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .matchedGeometryEffect(id: index, in: animation)
                                                    .padding()
                                                if model.data.frames[index].favorited {
                                                    VStack {
                                                        Spacer()
                                                        HStack {
                                                            Spacer()
                                                            Image(systemName: "heart.fill")
                                                                .foregroundColor(.red)
                                                                .font(.system(size: geometry.size.width / 20))
                                                                .padding(8)
                                                        }
                                                    }
                                                }
                                            }
                                            .frame(height: geometry.size.width / 3)
                                        }
                                    } else {
                                        Rectangle()
                                            .foregroundColor(colorscheme == .dark ? .white : .black)
                                            .opacity(index % 2 != 0 ? 0 : colorscheme == .dark ? 0.07 : 0.03)
                                            .frame(height: geometry.size.width / 3)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Augmented Frames")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if model.data.isFocused != -1 {
                        Button(action: {
                            withAnimation {
                                model.data.isFocused = -1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                model.data.welcome.toggle()
                            }
                        }) {
                            Image(systemName: "rectangle")
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if model.data.isFocused != -1 {
                        Button(action: {
                            model.data.isAugmenting.toggle()
                        }) {
                            Text("AR")
                        }
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    if model.data.isFocused != -1 {
                        HStack {
                            Button(action: {
                                model.data.isEditing.toggle()
                            }) {
                                Text("Edit")
                            }
                            Spacer()
                            Button(action: {
                                model.data.frames[model.data.selected].favorited.toggle()
                            }) {
                                Image(systemName: model.data.frames[model.data.selected].favorited ? "heart.fill" : "heart")
                            }
                            Spacer()
                            Button(action: {
                                model.removeImage(index: model.data.selected)
                                model.data.isFocused = -1
                            }) {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $model.data.welcome) {
            Welcome(model: model)
                .modifier(DisableModalDismiss(disabled: true))
        }
        .sheet(isPresented: $model.data.isEditing) {
            Editor(model: model)
                .modifier(DisableModalDismiss(disabled: model.data.isCreating ? true : false))
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
