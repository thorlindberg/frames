// source: https://typesafely.substack.com/p/add-a-camera-feed-to-swiftui

import UIKit
import AVFoundation

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

import SwiftUI
import AVFoundation

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
