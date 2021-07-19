import SwiftUI

struct Browse: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        ScrollStack(items: model.data.frames.count, direction: UIDevice.current.userInterfaceIdiom == .pad ? .horizontal : .vertical, size: 480, selection: $model.data.selected) {
            ForEach(Array(model.data.frames.indices), id: \.self) { index in
                Image(uiImage: model.data.frames[index].transform)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: UIDevice.current.userInterfaceIdiom == .pad ? 480 : nil,
                        height: UIDevice.current.userInterfaceIdiom == .pad ? nil : 480
                    )
                    .padding(UIDevice.current.userInterfaceIdiom == .pad ? .vertical : .horizontal, 28)
                    .opacity(model.data.welcome ? 1 : index == model.data.selected ? 1 : 0.3)
                    .onAppear {
                        model.transformImage(index: index)
                    }
                    .contextMenu {
                        if !model.data.welcome && index == model.data.selected {
                            Button(action: {
                                UIApplication.shared.windows.filter({$0.isKeyWindow})
                                    .first?
                                    .rootViewController?
                                    .present(UIActivityViewController(activityItems: [model.data.frames[index].transform], applicationActivities: nil), animated: true)
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
                        if model.data.welcome {
                            model.data.guide = "customize"
                        }
                        if UIDevice.current.userInterfaceIdiom != .pad && index == model.data.selected {
                            model.data.isEditing.toggle()
                        }
                    }
            }
        }
    }
    
}

struct Browse_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12")
    }
}
