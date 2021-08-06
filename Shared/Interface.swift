import SwiftUI
import UIKit
import AVFoundation

struct Interface: View {
    
    @ObservedObject var model: Model
    var device: GeometryProxy
    
    var body: some View {
        VStack {
            Spacer()
            if !model.data.isAugmenting {
                if model.data.isFramed {
                    Image(uiImage: model.data.frame!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical, 30)
                        .padding(.top, 30)
                        .padding(.bottom, 30 - 15)
                    Spacer()
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
                                Blur(style: .systemUltraThinMaterialDark)
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
                                Blur(style: .systemUltraThinMaterialDark)
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
                            Blur(style: .systemUltraThinMaterialDark)
                                .mask(Circle())
                        } else if model.data.isFramed {
                            Circle()
                                .foregroundColor(.white)
                        } else {
                            Blur(style: .light)
                                .mask(Circle())
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
                .disabled(!model.data.isFramed || model.data.isAdjusting)
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
                                Blur(style: .systemUltraThinMaterialDark)
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
                    if model.data.isAdjusting {
                        Button(action: {
                            model.data.isAdjusting.toggle()
                        }) {
                            ZStack {
                                ZStack {
                                    Circle()
                                        .foregroundColor(.white)
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
                    } else {
                        Menu {
                            Button(action: {
                                model.data.isAdjusting.toggle()
                            }) {
                                Label("Manually measure", systemImage: "square.and.pencil")
                            }
                            Button(action: {
                                model.data.isAdjusting.toggle()
                            }) {
                                Label("Measure in AR", systemImage: "move.3d")
                            }
                        } label: {
                            ZStack {
                                ZStack {
                                    Blur(style: .systemUltraThinMaterialDark)
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
                }
                Spacer()
            }
        }
        .padding(.bottom, 15)
    }
    
}
