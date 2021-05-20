import SwiftUI
import SceneKit

struct Frame: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        VStack(spacing: 0) {
            if model.data.frames.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "photo")
                        .opacity(0.15)
                        .font(.system(size: 150))
                    Spacer()
                }
                Spacer()
            } else {
                SceneView(scene: model.scene, pointOfView: model.camera, options: model.data.isAdjusting ? [] : [.allowsCameraControl])
                Adjustment(model: model)
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Augmented Frames")
        .onAppear { model.transformImage() }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    model.data.isAdjusting = false
                    model.data.isAction.toggle()
                }) {
                    Image(systemName: "camera")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    model.data.isAugmenting.toggle()
                }) {
                    Text("AR")
                }
                .disabled(model.data.frames.isEmpty)
            }
        }
    }
    
}

struct Border: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        Slider(
            value: $model.data.frames[model.data.selected].border,
            in: 0.05...0.95,
            onEditingChanged: { _ in
                model.transformImage()
            }
        )
        .padding(.horizontal)
    }
    
}

struct Style: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(model.materials, id: \.self) { material in
                    ZStack {
                        Rectangle()
                            .foregroundColor(material == model.data.frames[model.data.selected].material ? .accentColor : nil)
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
                }
            }
            .padding(.horizontal)
        }
    }
    
}

struct Crop: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(model.sizes, id: \.self) { size in
                    ZStack {
                        Rectangle()
                            .foregroundColor(size.width == model.data.frames[model.data.selected].width && size.height == model.data.frames[model.data.selected].height ? .accentColor : nil)
                            .opacity(size.width == model.data.frames[model.data.selected].width && size.height == model.data.frames[model.data.selected].height ? 1 : 0.05)
                            .cornerRadius(1000)
                            .frame(height: 30)
                        Text("\(Int(size.width))x\(Int(size.height))")
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
    
}

struct Adjustment: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if model.data.isBordering {
                Border(model: model)
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
        .frame(height: 80)
        ZStack {
            /*
            HStack {
                Button(action: {
                    model.removeImage()
                }) {
                    Text("Delete")
                        .foregroundColor(.red)
                }
                Spacer()
                Button(action: {
                    UIApplication.shared.windows.filter({$0.isKeyWindow})
                        .first?.rootViewController?
                        .present(UIActivityViewController(activityItems: [model.data.frames[model.data.selected].transform], applicationActivities: nil), animated: true)
                }) {
                    Text("Share")
                }
            }
            */
            HStack {
                Spacer()
                HStack(spacing: 25) {
                    Button(action: {
                        model.data.fromLeft = true
                        withAnimation {
                            model.toggleAdjust()
                            model.data.isBordering = true
                        }
                    }) {
                        Image(systemName: "square.dashed")
                            .foregroundColor(model.data.isBordering ? nil : colorScheme == .dark ? .white : .black)
                            .font(.system(size: 22))
                    }
                    Button(action: {
                        withAnimation {
                            model.toggleAdjust()
                            model.data.isStyling = true
                        }
                    }) {
                        Image(systemName: "cube")
                            .foregroundColor(model.data.isStyling ? nil : colorScheme == .dark ? .white : .black)
                            .font(.system(size: 22))
                    }
                    Button(action: {
                        model.data.fromLeft = false
                        withAnimation {
                            model.toggleAdjust()
                            model.data.isAdjusting = true
                        }
                    }) {
                        Image(systemName: "crop")
                            .foregroundColor(model.data.isAdjusting ? nil : colorScheme == .dark ? .white : .black)
                            .font(.system(size: 22))
                    }
                }
                Spacer()
            }
        }
        .padding()
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
