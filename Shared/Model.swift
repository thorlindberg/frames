import SwiftUI
import SceneKit
import VisionKit
import AVFoundation

final class Model: NSObject, ObservableObject {
    
    @Published var data: Format = Format()
    
    struct Format: Hashable {
        var colorscheme: ColorScheme?
        var welcome: Bool = !UserDefaults.standard.bool(forKey: "beta82")
        var guide: String = ""
        var isEditing: Bool = false
        var isImporting: Bool = false
        var isCapturing: Bool = false
        var isAugmenting: Bool = false
        var isFlashlight: Bool = false
        var isWarned: Bool = false
        var selected: Int = 0
        var frames: [Frame] = [
            Frame(image: UIImage(imageLiteralResourceName: "sample"), date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)),
            Frame(image: UIImage(imageLiteralResourceName: "sample2"), date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))
        ]
        var scene: SCNScene? {

            // create scene and box
            let scene = SCNScene()
            let node = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 0.02, chamferRadius: 0))
            
            // set scene background
            scene.background.contents = colorscheme == .dark ? UIColor.systemGray6 : UIColor.white
            
            // define materials
            let front = SCNMaterial()
            front.diffuse.contents = frames[selected].framed
            
            let frame = SCNMaterial()
            frame.diffuse.contents = frames[selected].material
            frame.diffuse.wrapT = SCNWrapMode.repeat
            frame.diffuse.wrapS = SCNWrapMode.repeat
            
            // add materials to sides
            node.geometry?.materials = [front, frame, frame, frame, frame, frame]
            
            // frame size
            node.scale = SCNVector3(
                Float(frames[selected].width/100),
                Float(frames[selected].height/100),
                1
            )
            
            // rotate frame
            node.rotation = SCNVector4(1, 0, 0, 350 * Double.pi / 180)
            
            // add frame to scene
            scene.rootNode.addChildNode(node)
            
            return scene
            
        }
    }
    
    struct Frame: Hashable {
        var image: UIImage
        var date: String
        var width: CGFloat = 60
        var height: CGFloat = 90
        var border: CGFloat = 0.05
        var material: UIImage = UIImage(named: "material_oak")!
        var filter: String = ""
        var framed: UIImage {
            
            // filter image
            var image: UIImage {
                switch filter {
                    case "noir":
                        return filterImage(image: self.image, filter: "noir")
                    case "mono":
                        return filterImage(image: self.image, filter: "mono")
                    case "invert":
                        return filterImage(image: self.image, filter: "invert")
                    default:
                        return self.image
                }
            }
            
            // set frame size
            let canvas = CGSize(
                width: image.size.width,
                height: image.size.width*(height/width)
            )
            
            // begin image
            UIGraphicsBeginImageContextWithOptions(canvas, false, CGFloat(0))
            
            // set frame material
            let front = CGRect(x: 0, y: 0, width: canvas.width, height: canvas.height)
            material.drawAsPattern(in: front)
            UIRectFill(front)
            
            // set border size
            let border = canvas.width * border / 2
            
            // fill with dominant color in image
            image.averageColor!.setFill()
            UIRectFill(
                CGRect(
                    x: border, y: border,
                    width: canvas.width - border * 2, height: canvas.height - border * 2
                )
            )
            
            // set image size
            var imageSize: CGRect {
                if image.size.height > canvas.height {
                    return CGRect(
                        x: border + (canvas.width - canvas.height*(image.size.width/image.size.height)) / 2,
                        y: border,
                        width: canvas.height * (image.size.width/image.size.height) - border * 2,
                        height: canvas.height - border * 2
                    )
                } else {
                    return CGRect(
                        x: border,
                        y: border + (canvas.height - canvas.width*(image.size.height/image.size.width)) / 2,
                        width: canvas.width - border * 2,
                        height: canvas.width * (image.size.height/image.size.width) - border * 2
                    )
                }
            }
            
            // draw image on frame
            image.draw(in: imageSize)
            
            // end image
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // update transformed image
            if let newImage = newImage {
                return newImage
            } else {
                return self.image
            }
            
        }
    }
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
    }
    
    func addImage(image: UIImage) {
        data.frames.insert(Frame(image: image, date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)), at: 0)
        data.selected = 0
    }
    
    func removeImage(index: Int) {
        data.frames.remove(at: index)
    }
    
}

func filterImage(image: UIImage, filter: String) -> UIImage {
    var effect: CIFilter? {
        switch filter {
            case "noir":
                return CIFilter(name: "CIPhotoEffectNoir")
            case "mono":
                return CIFilter(name: "CIPhotoEffectNoir")
            case "invert":
                return CIFilter(name: "CIColorInvert")
            default:
                return nil
        }
    }
    if let effect = effect {
        let context = CIContext(options: nil)
        effect.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        if let output = effect.outputImage, let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }
    }
    return image
}

extension Model: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for i in 0..<scan.pageCount {
            addImage(image: scan.imageOfPage(at:i))
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

// source: https://www.hackingwithswift.com/books/ios-swiftui/importing-an-image-into-swiftui-using-uiimagepickercontroller

struct ImagePicker: UIViewControllerRepresentable {
    
    @ObservedObject var model: Model
    var type: String
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if type == "import" {
            picker.sourceType = .photoLibrary
        }
        if type == "capture" {
            picker.sourceType = .camera
        }
        return picker
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) { }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.model.addImage(image: uiImage)
            }
            if parent.model.data.welcome {
                withAnimation {
                    parent.model.data.guide = ""
                }
            } else {
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
}

struct Model_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
