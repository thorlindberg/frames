import SwiftUI
import UIKit
import AVFoundation

struct Window: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        GeometryReader { device in
            ZStack {
                if model.data.isAugmenting {
                    ARViewContainer(model: model)
                        .ignoresSafeArea()
                } else {
                    CameraView()
                        .ignoresSafeArea()
                }
                Blur(style: .regular)
                    .opacity(model.data.isBlurred ? 1 : 0)
                    .ignoresSafeArea()
                Interface(model: model, device: device)
            }
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
            .previewDevice("iPhone 12 mini")
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
