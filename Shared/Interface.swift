import SwiftUI
import UIKit
import AVFoundation

struct Interface: View {
    
    @ObservedObject var model: Model
    var device: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            if !model.data.isAugmenting {
                Image(uiImage: model.data.frame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(50)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
                Spacer()
                HStack(spacing: 15) {
                    Menu {
                        ForEach(Array(stride(from: 10, to: 201, by: 5)), id: \.self) { value in
                            Button(action: {
                                withAnimation {
                                    model.data.width = CGFloat(value)
                                }
                            }) {
                                if model.data.width == CGFloat(value) {
                                    Label("\(value) cm", systemImage: "checkmark")
                                } else {
                                    Text("\(value) cm")
                                }
                            }
                            .disabled(model.data.width == CGFloat(value))
                        }
                    } label: {
                        ZStack {
                            Blur(style: .dark)
                                .mask(Capsule())
                            Text("width: \(Int(model.data.width)) cm")
                        }
                        .frame(width: 150, height: 35)
                    }
                    .accentColor(.white)
                    Menu {
                        ForEach(Array(stride(from: 10, to: 201, by: 5)), id: \.self) { value in
                            Button(action: {
                                withAnimation {
                                    model.data.height = CGFloat(value)
                                }
                            }) {
                                if model.data.height == CGFloat(value) {
                                    Label("\(value) cm", systemImage: "checkmark")
                                } else {
                                    Text("\(value) cm")
                                }
                            }
                            .disabled(model.data.height == CGFloat(value))
                        }
                    } label: {
                        ZStack {
                            Blur(style: .dark)
                                .mask(Capsule())
                            Text("height: \(Int(model.data.height)) cm")
                        }
                        .frame(width: 150, height: 35)
                    }
                    .accentColor(.white)
                }
            }
            HStack {
                Spacer()
                if model.data.isAugmenting {
                    Button(action: {
                        model.data.isFlashlight.toggle()
                        toggleTorch(on: model.data.isFlashlight)
                    }) {
                        ZStack {
                            ZStack {
                                Blur(style: .dark)
                                    .mask(Circle())
                                Image(systemName: model.data.isFlashlight ? "bolt.fill" : "bolt.slash")
                                    .font(.system(size: 20))
                            }
                            .frame(width: 50, height: 50)
                            Rectangle()
                                .opacity(0)
                                .frame(width: 100, height: 100)
                        }
                    }
                } else {
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
                        ZStack {
                            ZStack {
                                Blur(style: .dark)
                                    .mask(Circle())
                                Image(systemName: "camera.fill")
                            }
                            .frame(width: 50, height: 50)
                            Rectangle()
                                .opacity(0)
                                .frame(width: 100, height: 100)
                        }
                    }
                    .disabled(model.data.isAdjusting)
                }
                Spacer()
                Button(action: {
                    if !model.data.isAugmenting {
                        model.writeScene() // writes frame to app documents
                    } else {
                        model.data.isFlashlight = false
                        toggleTorch(on: model.data.isFlashlight)
                    }
                    withAnimation {
                        model.data.isAugmenting.toggle()
                        model.data.isBlurred.toggle()
                    }
                }) {
                    ZStack {
                        if model.data.isAdjusting {
                            Blur(style: .dark)
                                .mask(Circle())
                        } else {
                            Circle()
                                .foregroundColor(.white)
                        }
                        Image(systemName: "arrow.up")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                            .rotation3DEffect(
                                .degrees(model.data.isAugmenting ? 180 : 0),
                                axis: (x: 1.0, y: 0.0, z: 0.0)
                            )
                    }
                    .frame(width: 70, height: 70)
                }
                .disabled(model.data.isAdjusting)
                Spacer()
                if model.data.isAugmenting {
                    Menu {
                        Button(action: {
                            model.data.alignment = "none"
                        }) {
                            Label("No alignment", systemImage: model.data.alignment == "none" ? "checkmark" : "dot.arrowtriangles.up.right.down.left.circle")
                        }
                        .disabled(model.data.alignment == "none")
                        Button(action: {
                            model.data.alignment = "vertical"
                        }) {
                            Label("Vertical alignment", systemImage: model.data.alignment == "vertical" ? "checkmark" : "rectangle.arrowtriangle.2.inward")
                        }
                        .disabled(model.data.alignment == "vertical")
                        Button(action: {
                            model.data.alignment = "horizontal"
                        }) {
                            Label("Horizontal alignment", systemImage: model.data.alignment == "horizontal" ? "checkmark" : "rectangle.portrait.arrowtriangle.2.inward")
                        }
                        .disabled(model.data.alignment == "horizontal")
                    } label: {
                        ZStack {
                            ZStack {
                                Blur(style: .dark)
                                    .mask(Circle())
                                Image(systemName: "perspective")
                                    .font(.system(size: 20))
                            }
                            .accentColor(.orange)
                            .frame(width: 50, height: 50)
                            Rectangle()
                                .opacity(0)
                                .frame(width: 100, height: 100)
                        }
                    }
                } else {
                    Button(action: {
                        withAnimation {
                            model.data.isAdjusting.toggle()
                        }
                    }) {
                        ZStack {
                            ZStack {
                                if model.data.isAdjusting {
                                    Circle()
                                        .foregroundColor(.white)
                                } else {
                                    Blur(style: .dark)
                                        .mask(Circle())
                                }
                                Image(systemName: "cube")
                                    .font(.system(size: 20))
                            }
                            .accentColor(.orange)
                            .frame(width: 50, height: 50)
                            Rectangle()
                                .opacity(0)
                                .frame(width: 100, height: 100)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(.bottom, 15)
    }
    
}

struct Interface_Previews: PreviewProvider {
    static var previews: some View {
        Window(model: Model())
            .previewDevice("iPhone 12 mini")
    }
}

/*
Spacer()
if !model.data.isAugmenting {
    if model.data.isAdjusting {
        VStack(spacing: 50) {
            HStack {
                Text("Width")
                Spacer()
                Menu {
                    ForEach(Array(stride(from: 10, to: 201, by: 5)), id: \.self) { value in
                        Button(action: {
                            withAnimation {
                                model.data.width = CGFloat(value)
                            }
                        }) {
                            if model.data.width == CGFloat(value) {
                                Label("\(value) cm", systemImage: "checkmark")
                            } else {
                                Text("\(value) cm")
                            }
                        }
                        .disabled(model.data.width == CGFloat(value))
                    }
                } label: {
                    Text("\(Int(model.data.width)) cm")
                }
            }
            HStack {
                Text("Height")
                Spacer()
                Menu {
                    ForEach(Array(stride(from: 10, to: 201, by: 5)), id: \.self) { value in
                        Button(action: {
                            withAnimation {
                                model.data.height = CGFloat(value)
                            }
                        }) {
                            if model.data.height == CGFloat(value) {
                                Label("\(value) cm", systemImage: "checkmark")
                            } else {
                                Text("\(value) cm")
                            }
                        }
                        .disabled(model.data.height == CGFloat(value))
                    }
                } label: {
                    Text("\(Int(model.data.height)) cm")
                }
            }
            HStack {
                Text("Border")
                Spacer()
                Menu {
                    ForEach(Array(stride(from: 0.01, to: 0.51, by: 0.01)), id: \.self) { value in
                        Button(action: {
                            withAnimation {
                                model.data.border = CGFloat(value)
                            }
                        }) {
                            if model.data.border == CGFloat(value) {
                                Label("\(Int(value * 100)) %", systemImage: "checkmark")
                            } else {
                                Text("\(Int(value * 100)) %")
                            }
                        }
                        .disabled(model.data.border == CGFloat(value))
                    }
                } label: {
                    Text("\(Int(model.data.border * 100)) %")
                }
            }
        }
        .padding(.horizontal, 50)
        .transition(.scale(scale: 1.2).combined(with: .opacity))
        Spacer()
    } else if model.data.isFramed {
        
    } else {
        ZStack {
            HStack(alignment: .bottom) {
                Spacer()
                Rectangle()
                    .frame(width: 3, height: (device.size.height - 130 - 100) / 6 * 6)
                Spacer()
                Rectangle()
                    .frame(width: 3, height: (device.size.height - 130 - 100) / 6 * 1)
                    .padding(.horizontal, 67 / 2)
                Spacer()
                Rectangle()
                    .frame(width: 3, height: (device.size.height - 130 - 100) / 6 * 4)
                Spacer()
            }
            .opacity(0.25)
            VStack {
                Text("Add photo")
                Text("for augmentation")
                Spacer()
                Text("Define dimensions")
                Text("manually or with AR")
                Spacer()
                Text("Push photo into")
                Text("Augmented Reality")
                    .padding(.bottom, (device.size.height - 130 - 100) / 6 * 1 + 30)
            }
            .opacity(0.75)
            .frame(height: (device.size.height - 130 - 100) / 6 * 6)
        }
        .foregroundColor(.white)
        .transition(.scale(scale: 0.6).combined(with: .opacity))
    }
}
*/
