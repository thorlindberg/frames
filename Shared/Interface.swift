import SwiftUI
import UIKit
import AVFoundation

struct Interface: View {
    
    @ObservedObject var model: Model
    var device: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            if !model.data.isPlaced {
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        HStack(spacing: 20) {
                            ForEach(model.data.frames.indices, id: \.self) { index in
                                Image(uiImage: model.data.frames[index].frame)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: device.size.width - 80)
                                    .opacity(model.data.selected == index ? 1 : 1/3)
                                    .id(index)
                                    .contextMenu {
                                        Button(action: {
                                            UIApplication.shared.windows.filter({$0.isKeyWindow})
                                                .first?
                                                .rootViewController?
                                                .present(UIActivityViewController(activityItems: [model.data.frames[index].frame], applicationActivities: nil), animated: true)
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
                                    .padding(.top, 40)
                                    .padding(.bottom, 40 - 15)
                            }
                        }
                        .onChange(of: model.data.frames.count) { _ in
                            withAnimation {
                                proxy.scrollTo(model.data.frames.count > 1 ? 1 : 0, anchor: .center)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
                Spacer()
            }
            HStack {
                Spacer()
                if model.data.isPlaced {
                    Menu {
                        Button(action: {
                            model.data.alignment = "none"
                        }) {
                            Label("No alignment", systemImage: model.data.alignment == "none" ? "checkmark" : "")
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
                    .disabled(true)
                    .opacity(0)
                } else if model.data.selected != 0 {
                    Button(action: {
                        withAnimation {
                            model.removeImage(index: model.data.selected)
                        }
                    }) {
                        ZStack {
                            ZStack {
                                Blur(style: .dark)
                                    .mask(Circle())
                                Image(systemName: "xmark")
                            }
                            .frame(width: 50, height: 50)
                            Rectangle()
                                .opacity(0)
                                .frame(width: 100, height: 100)
                        }
                    }
                    .accentColor(.red)
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
                }
                Spacer()
                Button(action: {
                    model.data.isFlashlight = false
                    toggleTorch(on: model.data.isFlashlight)
                    if model.data.isAugmenting {
                        withAnimation {
                            model.data.isBlurred.toggle()
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                model.data.isBlurred.toggle()
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            model.data.isPlaced.toggle()
                        }
                    }
                    withAnimation {
                        model.data.isAugmenting.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.white)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                            .rotation3DEffect(
                                .degrees(model.data.isPlaced ? 180 : 0),
                                axis: (x: 1.0, y: 0.0, z: 0.0)
                            )
                    }
                    .frame(width: 70, height: 70)
                }
                .opacity(model.data.selected == 0 ? 1/5 : 1)
                .disabled(model.data.selected == 0)
                Spacer()
                if model.data.isPlaced {
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
                        Menu {
                            ForEach(Array(stride(from: 10, to: 201, by: 5)), id: \.self) { value in
                                Button(action: {
                                    withAnimation {
                                        model.data.frames[model.data.selected].width = CGFloat(value)
                                    }
                                }) {
                                    if model.data.frames[model.data.selected].width == CGFloat(value) {
                                        Label("\(value) cm", systemImage: "checkmark")
                                    } else {
                                        Text("\(value) cm")
                                    }
                                }
                                .disabled(model.data.frames[model.data.selected].width == CGFloat(value))
                            }
                        } label: {
                            Label("Width - \(Int(model.data.frames[model.data.selected].width)) cm", systemImage: "arrow.left.and.right")
                        }
                        Menu {
                            ForEach(Array(stride(from: 10, to: 201, by: 5)), id: \.self) { value in
                                Button(action: {
                                    withAnimation {
                                        model.data.frames[model.data.selected].height = CGFloat(value)
                                    }
                                }) {
                                    if model.data.frames[model.data.selected].height == CGFloat(value) {
                                        Label("\(value) cm", systemImage: "checkmark")
                                    } else {
                                        Text("\(value) cm")
                                    }
                                }
                                .disabled(model.data.frames[model.data.selected].height == CGFloat(value))
                            }
                        } label: {
                            Label("Height - \(Int(model.data.frames[model.data.selected].height)) cm", systemImage: "arrow.up.and.down")
                        }
                        Menu {
                            ForEach(Array(stride(from: 0.01, to: 0.51, by: 0.01)), id: \.self) { value in
                                Button(action: {
                                    withAnimation {
                                        model.data.frames[model.data.selected].border = CGFloat(value)
                                    }
                                }) {
                                    if model.data.frames[model.data.selected].border == CGFloat(value) {
                                        Label("\(Int(value * 100)) %", systemImage: "checkmark")
                                    } else {
                                        Text("\(Int(value * 100)) %")
                                    }
                                }
                                .disabled(model.data.frames[model.data.selected].border == CGFloat(value))
                            }
                        } label: {
                            Label("Border - \(Int(model.data.frames[model.data.selected].border * 100)) %", systemImage: "square.dashed")
                        }
                    } label: {
                        ZStack {
                            ZStack {
                                Blur(style: .dark)
                                    .mask(Circle())
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
                    .disabled(model.data.selected == 0)
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
