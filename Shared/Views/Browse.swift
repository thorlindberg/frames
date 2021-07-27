import SwiftUI

struct Browse: View {
    
    @ObservedObject var model: Model
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 7), count: 2), spacing: 7) {
                    ForEach(0...max(model.data.frames.count, 7), id: \.self) { index in
                        if index < model.data.frames.count {
                            NavigationLink(
                                destination: Editor(model: model),
                                isActive: Binding(
                                    get: { model.data.isEditing },
                                    set: { model.data.isEditing = $0 ; model.data.selected = index }
                                ),
                                label: {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(colorscheme == .dark ? .black : .white)
                                        Image(uiImage: model.data.frames[index].framed)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .padding()
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
                                    }
                                    .frame(height: geometry.size.width / 2)
                                }
                            )
                        } else {
                            Rectangle()
                                .foregroundColor(colorscheme == .dark ? .black : .white)
                                .frame(height: geometry.size.width / 2)
                        }
                    }
                }
            }
            .background(colorscheme == .dark ? Color(red: 1, green: 1, blue: 1, opacity: 0.6) : Color(red: 0, green: 0, blue: 0, opacity: 0.03))
        }
    }
    
}

struct Browse_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
