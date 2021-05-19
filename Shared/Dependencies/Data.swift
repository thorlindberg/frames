import SwiftUI
import SceneKit
import VisionKit
import AVFoundation

final class Data: NSObject, ObservableObject {
    
    struct Format: Hashable {
        var firstLaunch: Bool
        var isAction: Bool
        var isImporting: Bool
        var isAugmenting: Bool
        var isAugmented: Bool
        var isBordering: Bool
        var isStyling: Bool
        var isAdjusting: Bool
        var selected: Int
        var frames: [Frame]
    }
    
    struct Frame: Hashable {
        var image: UIImage
        var transform: UIImage
        var width: CGFloat
        var height: CGFloat
        var border: CGFloat
        var bordered: Bool
        var material: String
    }
    
    struct Size: Hashable {
        var width: CGFloat
        var height: CGFloat
    }
    
    @Published var data: Format = Format(
        firstLaunch: !UserDefaults.standard.bool(forKey: "hasLaunched"),
        isAction: false, isImporting: false, isAugmenting: false, isAugmented: false, isBordering: true, isStyling: false, isAdjusting: false,
        selected: 0,
        frames: [ Frame(
            image: UIImage(imageLiteralResourceName: "placeholder"), transform: UIImage(imageLiteralResourceName: "placeholder"),
            width: 50, height: 70, border: 0.05, bordered: true, material: "Oak"
        )]
    )
    
    let materials: [String] = ["White", "Black", "Oak", "Stone", "Marble"]
    
    let sizes: [Size] = [
        Size(width: 15, height: 30),
        Size(width: 30, height: 45),
        Size(width: 45, height: 60),
        Size(width: 50, height: 70),
        Size(width: 60, height: 90),
        Size(width: 90, height: 100)
    ]
    
    var camera: SCNNode? {
        // define and set pointofview
        let node = SCNNode()
        node.camera = SCNCamera()
        node.position = SCNVector3Make(0, 0, 1)
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
            case "Oak": frame.diffuse.contents = UIImage(named: "material_oak")
            case "Stone": frame.diffuse.contents = UIColor.gray
            case "Marble": frame.diffuse.contents = UIColor.blue
            default: frame.diffuse.contents = UIColor.white
        }
        
        // add materials to sides
        node.geometry?.materials = [front, frame, frame, frame, frame, frame]
        
        // frame size
        node.scale = SCNVector3(
            Float(data.frames[data.selected].width/100),
            Float(data.frames[data.selected].height/100),
            1
        )
        
        // add frame
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
                width: 50, height: 70,  border: 0.05,
                bordered: true, material: "Oak"
            ),
            at: 0
        )
        data.selected = 0
        transformImage()
    }
    
    func removeImage() {
        data.frames.remove(at: data.selected)
    }
    
    func toggleAdjust() {
        data.isBordering = false
        data.isStyling = false
        data.isAdjusting = false
    }
    
    func transformImage() {
        
        // resource: https://stackoverflow.com/a/39987845/15072454
        
        // reset transformed image
        data.frames[data.selected].transform = data.frames[data.selected].image
        let image = data.frames[data.selected].transform
        
        // set frame size
        let canvas = CGSize(
            width: image.size.width,
            height: image.size.width*(data.frames[data.selected].height/data.frames[data.selected].width)
        )
        
        // set image size
        let border = data.frames[data.selected].bordered ? canvas.width*data.frames[data.selected].border/2 : 0
        let imageSize = CGRect(
            x: border,
            y: (canvas.height - border - image.size.height) / 2,
            width: canvas.width-canvas.width*data.frames[data.selected].border,
            height: canvas.width*(image.size.height/image.size.width)-canvas.width*data.frames[data.selected].border
       )
        
        // begin transformation
        UIGraphicsBeginImageContextWithOptions(canvas, false, CGFloat(0))
        let context = UIGraphicsGetCurrentContext()!
        
        // set frame material
        switch data.frames[data.selected].material {
            case "Black": UIColor.black.setFill()
            case "Oak": UIColor.brown.setFill()
            case "Stone": UIColor.gray.setFill()
            case "Marble": UIColor.blue.setFill()
            default: UIColor.white.setFill()
        }
        UIRectFill(CGRect(
            x: 0, y: 0,
            width: canvas.width,
            height: canvas.height
        ))
        
        // fill with white, minus border
        if data.frames[data.selected].bordered {
            UIColor.white.setFill()
            UIRectFill(CGRect(
                x: border, y: border,
                width: canvas.width - border * 2,
                height: canvas.height - border * 2
            ))
        }
        
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
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
}

struct Data_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
