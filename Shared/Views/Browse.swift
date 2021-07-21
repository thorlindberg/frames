import SwiftUI

struct Browse: View {
    
    @ObservedObject var model: Model
    @Environment(\.colorScheme) var colorscheme
    @State var isActive: Bool = false
    
    var body: some View {
        if !model.data.welcome {
            NavigationLink(destination: Editor(model: model), isActive: $isActive, label: { })
        }
        ScrollStack(items: model.data.frames.count, direction: UIDevice.current.userInterfaceIdiom == .pad ? .horizontal : .vertical, size: 480, selection: $model.data.selected) {
            ForEach(Array(model.data.frames.indices), id: \.self) { index in
                Image(uiImage: model.data.frames[index].framed)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: UIDevice.current.userInterfaceIdiom == .pad ? 480 : nil,
                        height: UIDevice.current.userInterfaceIdiom == .pad ? nil : 480
                    )
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? nil : 28)
                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 56 : nil)
                    .opacity(index == model.data.selected ? 1 : 0.3)
                    .contextMenu {
                        if !model.data.welcome && index == model.data.selected {
                            Button(action: {
                                UIApplication.shared.windows.filter({$0.isKeyWindow})
                                    .first?
                                    .rootViewController?
                                    .present(UIActivityViewController(activityItems: [model.data.frames[index].framed], applicationActivities: nil), animated: true)
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            if model.data.frames.count > 1 {
                                Button(action: {
                                    model.removeImage(index: index)
                                }) {
                                    Label("Delete", systemImage: "delete.left")
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        if UIDevice.current.userInterfaceIdiom != .pad && index == model.data.selected {
                            isActive.toggle()
                        }
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    model.data.welcome.toggle()
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
        }
    }
    
}

struct Browse_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12")
    }
}
