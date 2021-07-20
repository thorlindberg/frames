import SwiftUI
import SceneKit
import VisionKit
import AVFoundation

final class Data: NSObject, ObservableObject {
    
    struct Format: Hashable {
        var colorscheme: ColorScheme?
        var welcome: Bool
        var guide: String
        var reload: Bool
        var isImporting: Bool
        var isCapturing: Bool
        var isAugmenting: Bool
        var isFlashlight: Bool
        var selected: Int
        var frames: [Frame]
        var feedback: Contact
        var camera: SCNNode? {
            let node = SCNNode()
            node.camera = SCNCamera()
            node.position = SCNVector3Make(0, 0, 1.3)
            return node
        }
        var scene: SCNScene? {
            
            // create scene and box
            let scene = SCNScene()
            let node = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 0.02, chamferRadius: 0))
            
            // set scene background
            scene.background.contents = colorscheme == .dark ? UIColor.systemGray6 : UIColor.white
            
            // define materials
            let front = SCNMaterial()
            front.diffuse.contents = frames[selected].transform
            
            let frame = SCNMaterial()
            switch frames[selected].material {
                case "Oak": frame.diffuse.contents = UIImage(named: "material_oak")
                case "Steel": frame.diffuse.contents = UIImage(named: "material_steel")
                case "Marble": frame.diffuse.contents = UIImage(named: "material_marble")
                default: frame.diffuse.contents = UIColor.white
            }
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
        var width: CGFloat
        var height: CGFloat
        var border: CGFloat
        var filter: String
        var material: String
        var transform: UIImage {
            
            var image = image
            
            // filter image
            if filter != "None" {
                let context = CIContext(options: nil)
                var currentFilter = CIFilter(name: "CIPhotoEffectNoir")
                switch filter {
                    case "Noir": currentFilter = CIFilter(name: "CIPhotoEffectNoir")
                    case "Mono": currentFilter = CIFilter(name: "CIPhotoEffectMono")
                    case "Invert": currentFilter = CIFilter(name: "CIColorInvert")
                    default: return image
                }
                currentFilter!.setValue(CIImage(image: image), forKey: kCIInputImageKey)
                if let output = currentFilter?.outputImage,
                    let cgImage = context.createCGImage(output, from: output.extent) {
                    image = UIImage(cgImage: cgImage)
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
            switch material {
                case "Oak": UIImage(named: "material_oak")?.drawAsPattern(in: front)
                case "Steel": UIImage(named: "material_steel")?.drawAsPattern(in: front)
                case "Marble": UIImage(named: "material_marble")?.drawAsPattern(in: front)
                default: UIColor.white.setFill()
            }
            UIRectFill(front)
            
            // set border size
            let border = canvas.width*border/2
            
            // fill with dominant color in image
            image.averageColor!.setFill()
            UIRectFill(CGRect(x: border, y: border, width: canvas.width - border * 2, height: canvas.height - border * 2))
            
            // set image size
            var imageSize: CGRect {
                if image.size.height > canvas.height {
                    return CGRect(
                        x: border + (canvas.width - canvas.height*(image.size.width/image.size.height)) / 2,
                        y: border,
                        width: canvas.height*(image.size.width/image.size.height)-canvas.width*border,
                        height: canvas.height-canvas.width*border
                    )
                } else {
                    return CGRect(
                        x: border,
                        y: border + (canvas.height - canvas.width*(image.size.height/image.size.width)) / 2,
                        width: canvas.width-canvas.width*border,
                        height: canvas.width*(image.size.height/image.size.width)-canvas.width*border
                    )
                }
            }
            
            // draw image on frame
            image.draw(in: imageSize)
            
            // end image
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // update transformed image
            return newImage!
            
        }
    }
    
    struct Contact: Hashable {
        var category: String
        var issue: String
        var description: String
        var email: String
        var focus: String
        var invalid: Bool
        var success: Bool
    }
    
    @Published var data: Format = Format(
        welcome: !UserDefaults.standard.bool(forKey: "v1.0"), guide: "", reload: false,
        isImporting: false, isCapturing: false, isAugmenting: false, isFlashlight: false,
        selected: 0, frames: [
            Frame(
                image: UIImage(imageLiteralResourceName: "sample"),
                width: 60, height: 90, border: 0.05, filter: "None", material: "Oak"
            ), Frame(
                image: UIImage(imageLiteralResourceName: "sample2"),
                width: 60, height: 90, border: 0.05, filter: "None", material: "Oak"
            )
        ],
        feedback: Contact(
            category: "", issue: "", description: "", email: "", focus: "",
            invalid: false, success: false
        )
    )
    
    let feedbackreset = Contact(
        category: "", issue: "", description: "", email: "", focus: "",
        invalid: false, success: false
    )
    
    let filters: [String] = ["None", "Noir", "Mono", "Invert"]
    let materials: [String] = ["Oak", "Steel", "Marble"]
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
    }
    
    func addImage(image: UIImage) {
        data.frames.insert(
            Frame(
                image: image, width: 60, height: 90, border: 0.05,
                filter: "None", material: "Oak"
            ),
            at: 0
        )
        reloadStack()
    }
    
    func removeImage(index: Int) {
        data.frames.remove(at: index)
        reloadStack()
    }
    
    func reloadStack() {
        data.selected = 0
        data.reload = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.data.reload = false
        }
    }
    
    func filterImage(filter: String) -> UIImage {
        var image = data.frames[data.selected].image
        let context = CIContext(options: nil)
        var currentFilter = CIFilter(name: "CIPhotoEffectNoir")
        switch filter {
            case "Noir": currentFilter = CIFilter(name: "CIPhotoEffectNoir")
            case "Mono": currentFilter = CIFilter(name: "CIPhotoEffectMono")
            case "Invert": currentFilter = CIFilter(name: "CIColorInvert")
            default: return image
        }
        currentFilter!.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        if let output = currentFilter?.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            image = UIImage(cgImage: cgImage)
        }
        return image
    }
    
}

extension Data: VNDocumentCameraViewControllerDelegate {
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

struct Model_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
