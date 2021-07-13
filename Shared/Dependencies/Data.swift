import SwiftUI
import SceneKit
import VisionKit
import AVFoundation

func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}

final class Data: NSObject, ObservableObject {
    
    struct Format: Hashable {
        var welcome: Bool
        var guide: String
        var isImporting: Bool
        var isEditing: Bool
        var isAugmenting: Bool
        var isFlashlight: Bool
        var isFiltering: Bool
        var isStyling: Bool
        var isAdjusting: Bool
        var fromLeft: Bool
        var selected: Int
        var frames: [Frame]
        var feedback: Contact
    }
    
    struct Frame: Hashable {
        var image: UIImage
        var transform: UIImage
        var size: Size
        var border: CGFloat
        var filter: String
        var material: String
    }
    
    struct Size: Hashable {
        var width: CGFloat
        var height: CGFloat
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
        welcome: !UserDefaults.standard.bool(forKey: "v1.0"), guide: "",
        isImporting: false, isEditing: false, isAugmenting: false, isFlashlight: false,
        isFiltering: false, isStyling: true, isAdjusting: false, fromLeft: false,
        selected: 0,
        frames: [Frame(
            image: UIImage(imageLiteralResourceName: "sample"),
            transform: UIImage(imageLiteralResourceName: "sample"),
            size: Size(width: 60, height: 90), border: 0.05, filter: "None", material: "Oak wood"
        )],
        feedback: Contact(
            category: "",
            issue: "",
            description: "",
            email: "",
            focus: "",
            invalid: false,
            success: false
        )
    )
    
    let feedbackreset = Contact(
        category: "",
        issue: "",
        description: "",
        email: "",
        focus: "",
        invalid: false,
        success: false
    )
    
    let filters: [String] = ["None", "Noir", "Monotone", "Invert colors"]
    let materials: [String] = ["Oak wood", "Polished steel", "Gray marble"]
    
    let sizes: [Size] = [
        Size(width: 60, height: 90),
        Size(width: 50, height: 70),
        Size(width: 45, height: 60),
        Size(width: 30, height: 45),
        Size(width: 15, height: 30)
    ]
    
    var camera: SCNNode? {
        let node = SCNNode()
        node.camera = SCNCamera()
        node.position = SCNVector3Make(0, 0, 1.1)
        return node
    }
    
    var scene: SCNScene? {
        
        // resource: https://stackoverflow.com/questions/24710609/swift-setting-scnmaterial-works-for-scnbox-but-not-for-scngeometry-loaded-from
        // resource: https://stackoverflow.com/questions/27509092/scnbox-different-colour-or-texture-on-each-face
        // resource: https://stackoverflow.com/questions/28480706/adding-camera-in-scnscene
        
        // create scene and box
        let scene = SCNScene()
        let node = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 0.02, chamferRadius: 0))
        
        // define materials
        let front = SCNMaterial()
        front.diffuse.contents = data.frames[data.selected].transform
        
        let frame = SCNMaterial()
        switch data.frames[data.selected].material {
            case "Black": frame.diffuse.contents = UIColor.black
            case "Orange": frame.diffuse.contents = UIColor.orange
            case "Green": frame.diffuse.contents = UIColor.green
            case "Oak wood": frame.diffuse.contents = UIImage(named: "material_oak")
            case "Polished steel": frame.diffuse.contents = UIImage(named: "material_steel")
            case "Gray marble": frame.diffuse.contents = UIImage(named: "material_marble")
            default: frame.diffuse.contents = UIColor.white
        }
        frame.diffuse.wrapT = SCNWrapMode.repeat
        frame.diffuse.wrapS = SCNWrapMode.repeat
        
        // add materials to sides
        node.geometry?.materials = [front, frame, frame, frame, frame, frame]
        
        // frame size
        node.scale = SCNVector3(
            Float(data.frames[data.selected].size.width/100),
            Float(data.frames[data.selected].size.height/100),
            1
        )
        
        // rotate frame
        node.rotation = SCNVector4(1, 0, 0, deg2rad(350))
        
        // add frame to scene
        scene.rootNode.addChildNode(node)
        
        return scene
        
    }
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
    }
    
    func addImage(image: UIImage) {
        data.frames.insert(
            Frame(
                image: image, transform: image,
                size: Size(width: 60, height: 90), border: 0.05,
                filter: "None", material: "Oak wood"
            ),
            at: 0
        )
        data.selected = 0
        transformImage()
    }
    
    func removeImage(index: Int) {
        data.frames.remove(at: index)
    }
    
    func toggleAdjust() {
        data.isFiltering = false
        data.isStyling = false
        data.isAdjusting = false
    }
    
    func transformImage() {
        
        // resource: https://stackoverflow.com/a/39987845/15072454
        
        // reset transformed image
        data.frames[data.selected].transform = data.frames[data.selected].image
        var image = data.frames[data.selected].transform
        
        // convert image to JPEG
        if let jpegData = image.jpegData(compressionQuality: 1.0) {
            image = UIImage(data: jpegData)!
        }
        
        // filter image
        // resource: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
        // source: https://stackoverflow.com/questions/40178846/convert-uiimage-to-grayscale-keeping-image-quality
        if data.frames[data.selected].filter != "None" {
            let context = CIContext(options: nil)
            var currentFilter = CIFilter(name: "CIPhotoEffectNoir")
            switch data.frames[data.selected].filter {
                case "Noir": currentFilter = CIFilter(name: "CIPhotoEffectNoir")
                case "Mono": currentFilter = CIFilter(name: "CIPhotoEffectMono")
                case "Invert": currentFilter = CIFilter(name: "CIColorInvert")
                default: return
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
            height: image.size.width*(data.frames[data.selected].size.height/data.frames[data.selected].size.width)
        )
        
        // set image size
        let border = canvas.width*data.frames[data.selected].border/2
        var imageSize = CGRect(
            x: border,
            y: border + (canvas.height - canvas.width*(image.size.height/image.size.width)) / 2,
            width: canvas.width-canvas.width*data.frames[data.selected].border,
            height: canvas.width*(image.size.height/image.size.width)-canvas.width*data.frames[data.selected].border
        )
        if image.size.height > canvas.height {
            imageSize = CGRect(
                x: border + (canvas.width - canvas.height*(image.size.width/image.size.height)) / 2,
                y: border,
                width: canvas.height*(image.size.width/image.size.height)-canvas.width*data.frames[data.selected].border,
                height: canvas.height-canvas.width*data.frames[data.selected].border
            )
        }
        
        // begin transformation
        UIGraphicsBeginImageContextWithOptions(canvas, false, CGFloat(0))
        
        // set frame material
        let front = CGRect(
            x: 0, y: 0,
            width: canvas.width,
            height: canvas.height
        )
        switch data.frames[data.selected].material {
            case "Black": UIColor.black.setFill()
            case "Orange": UIColor.orange.setFill()
            case "Green": UIColor.green.setFill()
            case "Oak wood": UIImage(named: "material_oak")?.drawAsPattern(in: front)
            case "Polished steel": UIImage(named: "material_steel")?.drawAsPattern(in: front)
            case "Gray marble": UIImage(named: "material_marble")?.drawAsPattern(in: front)
            default: UIColor.white.setFill()
        }
        UIRectFill(front)
        
        // fill with dominant color in image
        // source: https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
        
        image.averageColor!.setFill()
        UIRectFill(CGRect(
            x: border, y: border,
            width: canvas.width - border * 2,
            height: canvas.height - border * 2
        ))
        
        // draw image on frame
        image.draw(in: imageSize)
        
        // end transformation
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // update transformed image
        data.frames[data.selected].transform = newImage!
        
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

struct ImagePicker: UIViewControllerRepresentable {
    
    // source: https://www.hackingwithswift.com/books/ios-swiftui/importing-an-image-into-swiftui-using-uiimagepickercontroller
    
    @ObservedObject var model: Data
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
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
