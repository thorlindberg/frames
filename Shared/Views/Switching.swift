import SwiftUI

struct Switching: View {
    
    @Namespace private var animation
    @ObservedObject var model: Data
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView() {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                    ForEach((0...model.data.frames.count-1), id: \.self) { index in
                        Image(uiImage: model.data.frames[index].transform)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .contextMenu {
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
                                        withAnimation {
                                            model.removeImage(index: index)
                                            if model.data.frames.count == 1 {
                                                model.data.selected = 0
                                                model.toggleAdjust()
                                                model.data.isStyling = true
                                            }
                                        }
                                    }) {
                                        Label("Delete", systemImage: "delete.left")
                                    }
                                }
                            }
                            .matchedGeometryEffect(id: String(index), in: animation)
                            .onTapGesture {
                                model.data.selected = index
                                withAnimation {
                                    model.toggleAdjust()
                                    model.data.isStyling = true
                                }
                            }
                    }
                }
                .padding(30)
            }
        }
        .onAppear {
            model.transformImage()
        }
    }
    
}
