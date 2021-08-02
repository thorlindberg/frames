import SwiftUI
import AVFoundation

struct Augment: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        NavigationView {
            ARViewContainer()
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            model.data.isFlashlight = false
                            model.data.isAugmenting.toggle()
                        }) {
                            Text("Close")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            model.data.isFlashlight.toggle()
                            toggleTorch(on: model.data.isFlashlight)
                        }) {
                            HStack {
                                Text("Flash")
                                    .fontWeight(model.data.isFlashlight ? .bold : .regular)
                                Image(systemName: model.data.isFlashlight ? "bolt.fill" : "bolt.slash")
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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

struct Augment_Previews: PreviewProvider {
    static var previews: some View {
        Window(model: Model())
            .previewDevice("iPhone 12 mini")
    }
}
