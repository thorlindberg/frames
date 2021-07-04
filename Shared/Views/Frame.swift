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
        .navigationBarTitle("Frames")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Menu {
                    Button(action: {
                        model.data.isImporting.toggle()
                    }) {
                        Label("Import from Photos", systemImage: "photo")
                    }
                    Button(action: {
                        UIApplication.shared.windows.filter({$0.isKeyWindow})
                            .first?.rootViewController?
                            .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                    }) {
                        Label("Scan with Camera", systemImage: "viewfinder")
                    }
                } label: {
                    Image(systemName: "camera")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    model.data.isAugmenting.toggle()
                }) {
                    Text("AR")
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if !model.data.isSwitching {
                    Image(systemName: "square.on.square")
                        .font(.system(size: 20))
                        .opacity(0)
                    Spacer()
                    HStack(spacing: 30) {
                        Image(systemName: "camera.filters")
                            .font(.system(size: 20))
                            .foregroundColor(model.data.isFiltering ? .purple : nil)
                            .onTapGesture {
                                model.data.fromLeft = true
                                withAnimation {
                                    model.toggleAdjust()
                                    model.data.isFiltering = true
                                }
                            }
                        Image(systemName: "cube")
                            .font(.system(size: 20))
                            .foregroundColor(model.data.isStyling ? .green : nil)
                            .onTapGesture {
                                withAnimation {
                                    model.toggleAdjust()
                                    model.data.isStyling = true
                                }
                            }
                        Image(systemName: "selection.pin.in.out")
                            .font(.system(size: 20))
                            .foregroundColor(model.data.isAdjusting ? .orange : nil)
                            .onTapGesture {
                                model.data.fromLeft = false
                                withAnimation {
                                    model.toggleAdjust()
                                    model.data.isAdjusting = true
                                }
                            }
                    }
                    Spacer()
                    Image(systemName: "square.on.square")
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            withAnimation {
                                model.data.isSwitching.toggle()
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
                    ZStack {
                        Rectangle()
                            .foregroundColor(filter == model.data.frames[model.data.selected].filter ? .purple : .accentColor)
                            .opacity(filter == model.data.frames[model.data.selected].filter ? 1 : 0.05)
                            .cornerRadius(1000)
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
                    /*
                    Button(action: {
                        model.data.frames[model.data.selected].filter = filter
                        withAnimation {
                            model.transformImage()
                        }
                    }) {
                        Text(filter)
                            .padding(.horizontal, 5)
                    }
                    .buttonStyle(BorderedButtonStyle(tint: model.data.frames[model.data.selected].filter == filter ? .purple : .accentColor))
                    */
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
                    ZStack {
                        Rectangle()
                            .foregroundColor(material == model.data.frames[model.data.selected].material ? .green : .accentColor)
                            .opacity(material == model.data.frames[model.data.selected].material ? 1 : 0.05)
                            .cornerRadius(1000)
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
                    /*
                    Button(action: {
                        model.data.frames[model.data.selected].material = material
                        withAnimation {
                            model.transformImage()
                        }
                    }) {
                        ZStack {
                            Text(material)
                                .padding(.horizontal, 5)
                            Capsule()
                                .foregroundColor(material == model.data.frames[model.data.selected].material ? .green : .accentColor)
                        }
                    }
                    .buttonStyle(BorderedButtonStyle(tint: material == model.data.frames[model.data.selected].material ? .green : .accentColor))
                    */
                }
            }
            .padding(.horizontal)
        }
    }
    
}

struct Ratio: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(model.sizes, id: \.self) { size in
                    ZStack {
                        Rectangle()
                            .foregroundColor(size.width == model.data.frames[model.data.selected].width && size.height == model.data.frames[model.data.selected].height ? .orange : .accentColor)
                            .opacity(size.width == model.data.frames[model.data.selected].width && size.height == model.data.frames[model.data.selected].height ? 1 : 0.05)
                            .cornerRadius(1000)
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
                    /*
                    Button(action: {
                        model.data.frames[model.data.selected].width = size.width
                        model.data.frames[model.data.selected].height = size.height
                        withAnimation {
                            model.transformImage()
                        }
                    }) {
                        Text("\(Int(size.width))x\(Int(size.height)) cm")
                            .padding(.horizontal, 5)
                    }
                    .buttonStyle(BorderedButtonStyle(tint: size.width == model.data.frames[model.data.selected].width && size.height == model.data.frames[model.data.selected].height ? .orange : .accentColor))
                    */
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
                Ratio(model: model)
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
