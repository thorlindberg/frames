import SwiftUI
import SceneKit
import VisionKit
import AVFoundation

func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}

final class Data: NSObject, ObservableObject {
    
    struct Format: Hashable {
        var colorscheme: ColorScheme?
        var welcome: Bool
        var guide: String
        var reload: Bool
        var isBrowsing: Bool
        var isImporting: Bool
        var isCapturing: Bool
        var isAugmenting: Bool
        var isFlashlight: Bool
        var selected: Int
        var frames: [Frame]
        var feedback: Contact
    }
    
    struct Frame: Hashable {
        var image: UIImage
        var transform: UIImage {
            
            // resource: https://stackoverflow.com/a/39987845/15072454
            
            var transformation = image
            
            // convert image to JPEG
            if let jpegData = transformation.jpegData(compressionQuality: 1.0) {
                transformation = UIImage(data: jpegData)!
            }
            
            // filter image
            // resource: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
            // source: https://stackoverflow.com/questions/40178846/convert-uiimage-to-grayscale-keeping-image-quality
            if filter != "None" {
                let context = CIContext(options: nil)
                var currentFilter = CIFilter(name: "CIPhotoEffectNoir")
                switch filter {
                    case "Noir": currentFilter = CIFilter(name: "CIPhotoEffectNoir")
                    case "Mono": currentFilter = CIFilter(name: "CIPhotoEffectMono")
                    case "Invert": currentFilter = CIFilter(name: "CIColorInvert")
                    default: return image
                }
                currentFilter!.setValue(CIImage(image: transformation), forKey: kCIInputImageKey)
                if let output = currentFilter?.outputImage,
                    let cgImage = context.createCGImage(output, from: output.extent) {
                    transformation = UIImage(cgImage: cgImage)
                }
            }
            
            // set frame size
            let canvas = CGSize(
                width: transformation.size.width,
                height: transformation.size.width*(size.height/size.width)
            )
            
            // set image size
            let border = canvas.width*border/2
            var imageSize = CGRect(
                x: border,
                y: border + (canvas.height - canvas.width*(transformation.size.height/transformation.size.width)) / 2,
                width: canvas.width-canvas.width*border,
                height: canvas.width*(transformation.size.height/transformation.size.width)-canvas.width*border
            )
            if transformation.size.height > canvas.height {
                imageSize = CGRect(
                    x: border + (canvas.width - canvas.height*(transformation.size.width/transformation.size.height)) / 2,
                    y: border,
                    width: canvas.height*(transformation.size.width/transformation.size.height)-canvas.width*border,
                    height: canvas.height-canvas.width*border
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
            switch material {
                case "Oak": UIImage(named: "material_oak")?.drawAsPattern(in: front)
                case "Steel": UIImage(named: "material_steel")?.drawAsPattern(in: front)
                case "Marble": UIImage(named: "material_marble")?.drawAsPattern(in: front)
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
            transformation.draw(in: imageSize)
            
            // end transformation
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // update transformed image
            return newImage!
            
        }
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
        welcome: !UserDefaults.standard.bool(forKey: "v1.0"), guide: "", reload: false,
        isBrowsing: false, isImporting: false, isCapturing: false, isAugmenting: false, isFlashlight: false,
        selected: 0, frames: [
            Frame(
                image: UIImage(imageLiteralResourceName: "sample"),
                size: Size(width: 60, height: 90), border: 0.05, filter: "None", material: "Oak"
            ), Frame(
                image: UIImage(imageLiteralResourceName: "sample2"),
                size: Size(width: 60, height: 90), border: 0.05, filter: "None", material: "Oak"
            )
        ],
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
    
    let filters: [String] = ["None", "Noir", "Mono", "Invert"]
    let materials: [String] = ["Oak", "Steel", "Marble"]
    
    let sizes: [Size] = [ // deprecated
        Size(width: 60, height: 90),
        Size(width: 50, height: 70),
        Size(width: 45, height: 60),
        Size(width: 30, height: 45),
        Size(width: 15, height: 30)
    ]
    
    var camera: SCNNode? {
        let node = SCNNode()
        node.camera = SCNCamera()
        node.position = SCNVector3Make(0, 0, 1.3)
        return node
    }
    
    var scene: SCNScene? {
        
        // resource: https://stackoverflow.com/questions/24710609/swift-setting-scnmaterial-works-for-scnbox-but-not-for-scngeometry-loaded-from
        // resource: https://stackoverflow.com/questions/27509092/scnbox-different-colour-or-texture-on-each-face
        // resource: https://stackoverflow.com/questions/28480706/adding-camera-in-scnscene
        
        // create scene and box
        let scene = SCNScene()
        let node = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 0.02, chamferRadius: 0))
        
        // set scene background
        scene.background.contents = data.colorscheme == .dark ? UIColor.systemGray6 : UIColor.white
        
        // define materials
        let front = SCNMaterial()
        front.diffuse.contents = data.frames[data.selected].transform
        
        let frame = SCNMaterial()
        switch data.frames[data.selected].material {
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
            Float(data.frames[data.selected].size.width/100),
            Float(data.frames[data.selected].size.height/100),
            1
        )
        
        // rotate frame
        /* node.rotation = SCNVector4(1, 0, 0, deg2rad(350)) */
        
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
                image: image,
                size: Size(width: 60, height: 90), border: 0.05,
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
    
    /*
    var transformSelected: UIImage {
        
        // resource: https://stackoverflow.com/a/39987845/15072454
        
        let index = data.selected
        var image = data.frames[index].image
        
        // convert image to JPEG
        if let jpegData = image.jpegData(compressionQuality: 1.0) {
            image = UIImage(data: jpegData)!
        }
        
        // filter image
        // resource: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
        // source: https://stackoverflow.com/questions/40178846/convert-uiimage-to-grayscale-keeping-image-quality
        if data.frames[index].filter != "None" {
            let context = CIContext(options: nil)
            var currentFilter = CIFilter(name: "CIPhotoEffectNoir")
            switch data.frames[index].filter {
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
            height: image.size.width*(data.frames[index].size.height/data.frames[index].size.width)
        )
        
        // set image size
        let border = canvas.width*data.frames[index].border/2
        var imageSize = CGRect(
            x: border,
            y: border + (canvas.height - canvas.width*(image.size.height/image.size.width)) / 2,
            width: canvas.width-canvas.width*data.frames[index].border,
            height: canvas.width*(image.size.height/image.size.width)-canvas.width*data.frames[index].border
        )
        if image.size.height > canvas.height {
            imageSize = CGRect(
                x: border + (canvas.width - canvas.height*(image.size.width/image.size.height)) / 2,
                y: border,
                width: canvas.height*(image.size.width/image.size.height)-canvas.width*data.frames[index].border,
                height: canvas.height-canvas.width*data.frames[index].border
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
        switch data.frames[index].material {
            case "Oak": UIImage(named: "material_oak")?.drawAsPattern(in: front)
            case "Steel": UIImage(named: "material_steel")?.drawAsPattern(in: front)
            case "Marble": UIImage(named: "material_marble")?.drawAsPattern(in: front)
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
        return newImage!
        
    }
    */
    
    /*
    func transformImage(index: Int) {
        
        // resource: https://stackoverflow.com/a/39987845/15072454
        
        // reset transformed image
        data.frames[index].transform = data.frames[index].image
        var image = data.frames[index].transform
        
        // convert image to JPEG
        if let jpegData = image.jpegData(compressionQuality: 1.0) {
            image = UIImage(data: jpegData)!
        }
        
        // filter image
        // resource: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
        // source: https://stackoverflow.com/questions/40178846/convert-uiimage-to-grayscale-keeping-image-quality
        if data.frames[index].filter != "None" {
            let context = CIContext(options: nil)
            var currentFilter = CIFilter(name: "CIPhotoEffectNoir")
            switch data.frames[index].filter {
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
            height: image.size.width*(data.frames[index].size.height/data.frames[index].size.width)
        )
        
        // set image size
        let border = canvas.width*data.frames[index].border/2
        var imageSize = CGRect(
            x: border,
            y: border + (canvas.height - canvas.width*(image.size.height/image.size.width)) / 2,
            width: canvas.width-canvas.width*data.frames[index].border,
            height: canvas.width*(image.size.height/image.size.width)-canvas.width*data.frames[index].border
        )
        if image.size.height > canvas.height {
            imageSize = CGRect(
                x: border + (canvas.width - canvas.height*(image.size.width/image.size.height)) / 2,
                y: border,
                width: canvas.height*(image.size.width/image.size.height)-canvas.width*data.frames[index].border,
                height: canvas.height-canvas.width*data.frames[index].border
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
        switch data.frames[index].material {
            case "Oak": UIImage(named: "material_oak")?.drawAsPattern(in: front)
            case "Steel": UIImage(named: "material_steel")?.drawAsPattern(in: front)
            case "Marble": UIImage(named: "material_marble")?.drawAsPattern(in: front)
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
        data.frames[index].transform = newImage!
        
    }
    */
    
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

struct Data_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Editor(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12")
    }
}
