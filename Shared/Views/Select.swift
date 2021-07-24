import SwiftUI

struct Select: View {
    
    @ObservedObject var model: Model
    @Environment(\.colorScheme) var colorscheme
    @State var isActive: Bool = false
    var size: CGFloat = 480
    
    var body: some View {
        ScrollStack(
            items: model.data.frames.count,
            direction: UIDevice.current.userInterfaceIdiom == .pad ? .horizontal : .vertical,
            size: size, spacing: 14, selection: $model.data.selected
        ) {
            ForEach(Array(model.data.frames.indices), id: \.self) { index in
                Image(uiImage: model.data.frames[index].framed)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: UIDevice.current.userInterfaceIdiom == .pad ? size : nil,
                        height: UIDevice.current.userInterfaceIdiom == .pad ? nil : size
                    )
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? nil : 28)
                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 56 : nil)
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
                            model.data.isEditing.toggle()
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

struct Select_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12")
    }
}
