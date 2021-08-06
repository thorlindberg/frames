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
                Image(uiImage: model.data.frame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 40)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40 - 15)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                Spacer()
            }
            HStack {
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
                    if !model.data.isPlaced {
                        model.writeScene() // writes frame to app documents
                    } else {
                        model.data.isFlashlight = false
                        toggleTorch(on: model.data.isFlashlight)
                    }
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
                Spacer()
                if model.data.isPlaced {
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
                    Menu {
                        ForEach(Array(stride(from: 10, to: 201, by: 5)), id: \.self) { value in
                            Button(action: {
                                withAnimation {
                                    model.data.width = CGFloat(value)
                                    model.data.height = CGFloat(value)
                                }
                            }) {
                                if model.data.width == CGFloat(value) {
                                    Label("\(value)x\(value) cm", systemImage: "checkmark")
                                } else {
                                    Text("\(value)x\(value) cm")
                                }
                            }
                            .disabled(model.data.width == CGFloat(value))
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
