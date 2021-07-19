import SwiftUI

struct Browse: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        HStack(spacing: 14) {
            ForEach(Array(model.data.frames.indices), id: \.self) { index in
                Image(uiImage: model.data.frames[index].transform)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300)
                    .onAppear {
                        model.transformImage(index: index)
                    }
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
                                model.removeImage(index: index)
                            }) {
                                Label("Delete", systemImage: "delete.left")
                            }
                        }
                    }
            }
        }
        .modifier(ScrollingHStackModifier(items: model.data.frames.count, itemWidth: 300, itemSpacing: 14))
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
