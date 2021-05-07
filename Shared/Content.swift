import SwiftUI

struct Content: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            ZStack {
                Picture(model: model)
                if model.data.isAdjusting {
                    TabView(selection: $model.data.orientation) {
                        Adjust(model: model).tabItem { Label("Vertical", systemImage: "rectangle.portrait") }.tag("vertical")
                        Adjust(model: model).tabItem { Label("Horizontal", systemImage: "rectangle") }.tag("horizontal")
                        Adjust(model: model).tabItem { Label("Quadrant", systemImage: "square") }.tag("quadrant")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button(action: {
                        model.data.isPresented.toggle()
                    }) {
                        Image(systemName: "photo")
                    }
                    Button(action: {
                        model.data.isAdjusting.toggle()
                    }) {
                        Image(systemName: model.data.isAdjusting ? "aspectratio.fill" : "aspectratio")
                    }
                    .disabled(model.data.image == nil)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        //
                    }) {
                        Text("View in AR")
                            .fontWeight(.bold)
                    }
                    .disabled(model.data.image == nil || model.data.aspectratio.isEmpty)
                }
            }
        }
        .actionSheet(isPresented: $model.data.isPresented) {
            ActionSheet(title: Text("Add image"), buttons: [
                .default(Text("Import from Photos")) { model.data.isImporting.toggle() },
                .default(Text("Scan with Camera")) { UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.present(model.getDocumentCameraViewController(), animated: true, completion: nil) },
                .cancel()
            ])
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
    }
    
}
