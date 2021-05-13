import SwiftUI

struct Frame: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                if model.data.frames.isEmpty {
                    HStack {
                        Spacer()
                        Image(systemName: "photo")
                            .opacity(0.15)
                            .font(.system(size: 150))
                        Spacer()
                    }
                    Spacer()
                } else {
                    ZStack {
                        if model.data.frames[model.data.selected].bordered {
                            Rectangle()
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.15), radius: 30)
                                .padding(30)
                                .frame(width: model.data.frames[model.data.selected].filled ? geometry.size.width : nil)
                        }
                        Image(uiImage: model.data.frames[model.data.selected].image)
                            .resizable()
                            .aspectRatio(contentMode: model.data.frames[model.data.selected].filled ? .fill : .fit)
                            .saturation(model.data.frames[model.data.selected].colored ? 1 : 0)
                            .brightness(model.data.frames[model.data.selected].brightened ? 0.1 : 0)
                            .if(model.data.frames[model.data.selected].inverted) { view in view.colorInvert()}
                            .rotationEffect(.degrees(Double(model.data.frames[model.data.selected].rotated)))
                            .padding(model.data.frames[model.data.selected].bordered ? 40 : 30)
                            .frame(height: [Double(90), Double(270)].contains(abs(model.data.frames[model.data.selected].rotated)) ? geometry.size.width : nil)
                            .mask(Rectangle().frame(width: model.data.frames[model.data.selected].bordered ? geometry.size.width - 80 : geometry.size.width - 60, height: geometry.size.height))
                            .contextMenu {
                                Button(action: {
                                    UIApplication.shared.windows.filter({$0.isKeyWindow})
                                        .first?
                                        .rootViewController?
                                        .present(UIActivityViewController(activityItems: [model.data.frames[model.data.selected]], applicationActivities: nil), animated: true)
                                }) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                Button(action: {
                                    model.removeImage()
                                }) {
                                    Label("Delete", systemImage: "delete.left")
                                }
                            }
                    }
                    .frame(width: geometry.size.width, height: model.data.frames[model.data.selected].height >= model.data.frames[model.data.selected].width ? model.data.frames[model.data.selected].height / model.data.frames[model.data.selected].width * geometry.size.width : nil)
                    Spacer()
                    if model.data.frames.count != 1 {
                        VStack(spacing: 0) {
                            HStack(spacing: 10) {
                                ForEach((1...model.data.frames.count), id: \.self) { select in
                                    Circle()
                                        .opacity(select == model.data.selected + 1 ? 0.3 : 0.15)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .frame(height: 30)
                        }
                    }
                }
                
            }
            .gesture(DragGesture(minimumDistance: geometry.size.width/2).onChanged { value in
                if value.translation.width > 0 {
                    model.data.selected = model.data.selected - 1
                } else if model.data.selected != model.data.frames.count - 1 {
                    model.data.selected = model.data.selected + 1
                }
                if model.data.selected < 0 {
                    model.data.selected = 0
                }
            })
        }
    }
    
}

extension View {
    // source: https://www.avanderlee.com/swiftui/conditional-view-modifier/
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct Frame_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
