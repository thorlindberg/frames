import SwiftUI
import SceneKit

struct Frame: View {
    
    @Namespace private var animation
    @ObservedObject var model: Data
    
    var body: some View {
        VStack(spacing: 0) {
            if model.data.isSwitching {
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
            } else if model.data.frames[model.data.selected].transform != model.data.frames[model.data.selected].image {
                Spacer()
                Image(uiImage: model.data.frames[model.data.selected].transform)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(30)
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
                    .matchedGeometryEffect(id: String(model.data.selected), in: animation)
                Spacer()
                Adjustment(model: model)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            model.transformImage()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                HStack(spacing: 20) {
                    if #available(iOS 15.0, *) {
                        Button(action: {
                            model.data.isImporting.toggle()
                        }) {
                            Image(systemName: "photo")
                        }
                        Button(action: {
                            UIApplication.shared.windows.filter({$0.isKeyWindow})
                                .first?.rootViewController?
                                .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                        }) {
                            Image(systemName: "viewfinder")
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                if #available(iOS 15.0, *) {
                    Button(action: {
                        model.data.isAugmenting.toggle()
                    }) {
                        Text("AR")
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if !model.data.isSwitching {
                    HStack {
                        if model.data.frames.count > 1 {
                            Button(action: {
                                withAnimation {
                                    model.data.isSwitching.toggle()
                                }
                            }) {
                                Image(systemName: "square.on.square")
                                    .foregroundColor(.accentColor)
                            }
                            .opacity(0)
                            .disabled(true)
                        }
                        Spacer()
                        HStack(spacing: 30) {
                            Button(action: {
                                model.data.fromLeft = true
                                withAnimation {
                                    model.toggleAdjust()
                                    model.data.isFiltering = true
                                }
                            }) {
                                Image(systemName: "camera.filters")
                                    .foregroundColor(model.data.isFiltering ? .purple : nil)
                            }
                            Button(action: {
                                withAnimation {
                                    model.toggleAdjust()
                                    model.data.isStyling = true
                                }
                            }) {
                                Image(systemName: "cube")
                                    .foregroundColor(model.data.isStyling ? .green : nil)
                            }
                            Button(action: {
                                model.data.fromLeft = false
                                withAnimation {
                                    model.toggleAdjust()
                                    model.data.isAdjusting = true
                                }
                            }) {
                                Image(systemName: "crop")
                                    .foregroundColor(model.data.isAdjusting ? .orange : nil)
                            }
                        }
                        Spacer()
                        if model.data.frames.count > 1 {
                            Button(action: {
                                withAnimation {
                                    model.data.isSwitching.toggle()
                                }
                            }) {
                                Image(systemName: "square.on.square")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
        }
    }
    
}

struct Filter: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(model.filters, id: \.self) { filter in
                    if #available(iOS 15.0, *) {
                        Button(action: {
                            model.data.frames[model.data.selected].filter = filter
                            withAnimation {
                                model.transformImage()
                            }
                        }) {
                            Text(filter)
                        }
                        .buttonStyle(BorderedButtonStyle(tint: model.data.frames[model.data.selected].filter == filter ? .purple : .accentColor))
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
}

struct Style: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(model.materials, id: \.self) { material in
                    if #available(iOS 15.0, *) {
                        Button(action: {
                            model.data.frames[model.data.selected].material = material
                            withAnimation {
                                model.transformImage()
                            }
                        }) {
                            Text(material)
                        }
                        .buttonStyle(BorderedButtonStyle(tint: material == model.data.frames[model.data.selected].material ? .green : .accentColor))
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
}

struct Crop: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(model.sizes, id: \.self) { size in
                    if #available(iOS 15.0, *) {
                        Button(action: {
                            model.data.frames[model.data.selected].width = size.width
                            model.data.frames[model.data.selected].height = size.height
                            withAnimation {
                                model.transformImage()
                            }
                        }) {
                            Text("\(Int(size.width))x\(Int(size.height))")
                        }
                        .buttonStyle(BorderedButtonStyle(tint: size.width == model.data.frames[model.data.selected].width && size.height == model.data.frames[model.data.selected].height ? .orange : .accentColor))
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
}

struct Adjustment: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        ZStack {
            if model.data.isFiltering {
                Filter(model: model)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
            if model.data.isStyling {
                Style(model: model)
                    .transition(model.data.fromLeft ? .move(edge: .trailing).combined(with: .opacity) : .move(edge: .leading).combined(with: .opacity))
            }
            if model.data.isAdjusting {
                Crop(model: model)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.bottom)
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
