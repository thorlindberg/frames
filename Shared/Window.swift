import SwiftUI
import UIKit
import AVFoundation
import AVFoundation

struct Window: View {
    
    @ObservedObject var model: Model

    var body: some View {
        ZStack {
            if model.data.isAugmenting && !model.data.isReset {
                ARViewContainer(model: model)
                    .ignoresSafeArea()
            } else {
                CameraView()
                    .ignoresSafeArea()
            }
            if model.data.isBlurred {
                Blur(style: .dark)
                    .ignoresSafeArea()
            }
            VStack {
                Spacer()
                if !model.data.isAugmenting {
                    if let frame = model.data.frame {
                        Image(uiImage: frame)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(50)
                        Spacer()
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
                                Blur(style: .dark)
                                    .mask(Circle())
                                Image(systemName: model.data.isFlashlight ? "bolt.fill" : "bolt.slash")
                                    .font(.system(size: 20))
                            }
                            .frame(width: 50, height: 50)
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
                                Blur(style: .dark)
                                    .mask(Circle())
                                Image(systemName: "camera.fill")
                            }
                            .frame(width: 50, height: 50)
                        }
                    }
                    Spacer()
                    Button(action: {
                        if model.data.isAugmenting {
                            withAnimation {
                                model.data.isBlurred.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    model.data.isAugmenting.toggle()
                                }
                            }
                        } else {
                            withAnimation {
                                model.data.isAugmenting.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    model.data.isBlurred.toggle()
                                }
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                            Image(systemName: "arrow.up")
                                .font(.system(size: 30))
                                .rotation3DEffect(
                                    .degrees(model.data.isAugmenting ? 180 : 0),
                                    axis: (x: 1.0, y: 0.0, z: 0.0)
                                )
                        }
                        .frame(width: 70, height: 70)
                    }
                    Spacer()
                    if model.data.isAugmenting {
                        Button(action: {
                            withAnimation {
                                model.data.isReset.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation {
                                    model.data.isReset.toggle()
                                }
                            }
                        }) {
                            ZStack {
                                Blur(style: .dark)
                                    .mask(Circle())
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.system(size: 20))
                            }
                            .frame(width: 50, height: 50)
                        }
                    } else {
                        Button(action: {
                            //
                        }) {
                            ZStack {
                                Blur(style: .dark)
                                    .mask(Circle())
                                Image(systemName: "crop")
                                    .font(.system(size: 20))
                            }
                            .accentColor(.orange)
                            .frame(width: 50, height: 50)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 30)
        }
        .fullScreenCover(isPresented: $model.data.isImporting) {
            ImagePicker(model: model, type: "import")
                .preferredColorScheme(.dark)
        }
        .fullScreenCover(isPresented: $model.data.isCapturing) {
            ImagePicker(model: model, type: "capture")
                .preferredColorScheme(.dark)
        }
    }
    
}

struct Window_Previews: PreviewProvider {
    static var previews: some View {
        Window(model: Model())
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

func toggleTorch(on: Bool) {
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    if device.hasTorch {
        do {
            try device.lockForConfiguration()
            if on == true {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    } else {
        print("Torch is not available")
    }
}

// source: https://typesafely.substack.com/p/add-a-camera-feed-to-swiftui

class PreviewView: UIView {
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard
            let layer = layer as? AVCaptureVideoPreviewLayer
        else { fatalError("Could not get layer") }
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        return layer
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}

extension AVCaptureSession {
    convenience init(device: AVCaptureDevice.DeviceType) {
        self.init()
        beginConfiguration()
        guard
            let videoDevice = AVCaptureDevice.default(device,
                                                      for: AVMediaType.video,
                                                      position: .back),
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            canAddInput(videoDeviceInput)
        else { return }
        addInput(videoDeviceInput)
        commitConfiguration()
        startRunning()
    }
}

struct CameraView: UIViewRepresentable {
    let preview = PreviewView()
    func makeUIView(context: Context) -> PreviewView {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    preview.videoPreviewLayer.session = AVCaptureSession(device: .builtInWideAngleCamera)
                }
            }
        }
        return preview
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {}
}
