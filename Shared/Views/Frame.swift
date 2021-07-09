import SwiftUI
import SceneKit

struct Frame: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        VStack(spacing: 0) {
            if model.data.frames[model.data.selected].transform != model.data.frames[model.data.selected].image {
                Spacer()
                Image(uiImage: model.data.frames[model.data.selected].transform)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(28)
                    .contextMenu {
                        Button(action: {
                            UIApplication.shared.windows.filter({$0.isKeyWindow})
                                .first?
                                .rootViewController?
                                .present(UIActivityViewController(activityItems: [model.data.frames[model.data.selected].transform], applicationActivities: nil), animated: true)
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        if model.data.frames.count > 1 {
                            Button(action: {
                                model.removeImage(index: model.data.selected)
                            }) {
                                Label("Delete", systemImage: "delete.left")
                            }
                        }
                    }
                Spacer()
                Adjustment(model: model)
                    .padding(.bottom)
            }
        }
        .onAppear {
            model.transformImage()
        }
    }
    
}

struct Filter: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        HStack {
            ForEach(model.filters, id: \.self) { filter in
                ZStack {
                    Capsule()
                        .foregroundColor(filter == model.data.frames[model.data.selected].filter ? .purple : .accentColor)
                        .opacity(filter == model.data.frames[model.data.selected].filter ? 1 : colorscheme == .dark ? 0.1 : 0.05)
                        .frame(height: 30)
                    Text(filter)
                        .if (filter == model.data.frames[model.data.selected].filter) { view in
                            view.colorInvert()
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .padding()
                }
                .onTapGesture {
                    model.data.frames[model.data.selected].filter = filter
                    withAnimation {
                        model.transformImage()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
}

struct Style: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        HStack {
            ForEach(model.materials, id: \.self) { material in
                ZStack {
                    Capsule()
                        .foregroundColor(material == model.data.frames[model.data.selected].material ? .green : .accentColor)
                        .opacity(material == model.data.frames[model.data.selected].material ? 1 : colorscheme == .dark ? 0.1 : 0.05)
                        .frame(height: 30)
                    Text(material)
                        .if (material == model.data.frames[model.data.selected].material) { view in
                            view.colorInvert()
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .padding()
                }
                .onTapGesture {
                    model.data.frames[model.data.selected].material = material
                    withAnimation {
                        model.transformImage()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
}

struct Ratio: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        HStack {
            ForEach(model.sizes, id: \.self) { size in
                ZStack {
                    Capsule()
                        .foregroundColor(size.width == model.data.frames[model.data.selected].width && size.height == model.data.frames[model.data.selected].height ? .orange : .accentColor)
                        .opacity(size.width == model.data.frames[model.data.selected].width && size.height == model.data.frames[model.data.selected].height ? 1 : colorscheme == .dark ? 0.1 : 0.05)
                        .frame(height: 30)
                    Text("\(Int(size.width))x\(Int(size.height)) cm")
                        .if (size.width == model.data.frames[model.data.selected].width && size.height == model.data.frames[model.data.selected].height) { view in
                            view.colorInvert()
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .padding()
                }
                .onTapGesture {
                    model.data.frames[model.data.selected].width = size.width
                    model.data.frames[model.data.selected].height = size.height
                    withAnimation {
                        model.transformImage()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
}

struct Adjustment: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if model.data.isFiltering {
                Filter(model: model)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
            if model.data.isStyling {
                Style(model: model)
                    .transition(model.data.fromLeft ? .move(edge: .trailing).combined(with: .opacity) : .move(edge: .leading).combined(with: .opacity))
            }
            if model.data.isAdjusting {
                Ratio(model: model)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
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
