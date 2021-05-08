import SwiftUI

struct Content: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            TabView(selection: $model.data.orientation) {
                Framer(model: model)
                    .tabItem { Image(systemName: "rectangle.portrait") }
                    .tag("vertical")
                Framer(model: model)
                    .tabItem { Image(systemName: "rectangle") }
                    .tag("horizontal")
                Framer(model: model)
                    .tabItem { Image(systemName: "square") }
                    .tag("quadrant")
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Frames")
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Menu("Add") {
                        Button(action: {
                            model.data.isImporting.toggle()
                        }) {
                            Label("Import from Photos", systemImage: "photo")
                        }
                        Button(action: {
                            UIApplication.shared.windows.filter({$0.isKeyWindow})
                                .first?
                                .rootViewController?
                                .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                        }) {
                            Label("Scan with Camera", systemImage: "viewfinder")
                        }
                    }
                    /*
                    Button(action: {
                        // collage editor
                    }) {
                        Image(systemName: "square.grid.3x2")
                    }
                    */
                }
                ToolbarItem(placement: .confirmationAction) {
                    if model.data.images.count != 1 {
                        Menu("AR") {
                            Button(action: {
                                model.data.isAugmenting.toggle()
                            }) {
                                Label("View photo collage", systemImage: "square.grid.3x2")
                            }
                            Button(action: {
                                model.data.isAugmenting.toggle()
                            }) {
                                Label("View single photo", systemImage: "square")
                            }
                        }
                    } else {
                        Button(action: {
                            model.data.isAugmenting.toggle()
                        }) {
                            Text("View in AR")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model)
        }
        .sheet(isPresented: $model.data.firstLaunch) {
            VStack(spacing: 25) {
                Text("Welcome!")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                Spacer()
                Text("1. Scan/select image for framing")
                Divider().padding(.horizontal, 60)
                Text("2. Choose real-world frame size")
                Divider().padding(.horizontal, 60)
                Text("2. Preview framed image in AR")
                Spacer()
                Button(action: {
                    model.data.firstLaunch.toggle()
                }) {
                    Text("I'm ready to rock 🤟")
                }
            }
            .padding(.vertical, 100)
        }
        .sheet(isPresented: $model.data.isAugmenting) {
            VStack {
                HStack {
                    Button("Close") {
                        model.data.isAugmenting.toggle()
                    }
                    Spacer()
                }
                .padding()
                ARQuickLookView()
            }
        }
    }
    
}
