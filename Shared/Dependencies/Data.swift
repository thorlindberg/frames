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
        var isFiltering: Bool
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
    }
    
    @Published var data: Format = Format(
        firstLaunch: !UserDefaults.standard.bool(forKey: "hasLaunched"),
        isAction: false, isImporting: false, isAugmenting: false, isAugmented: false, isBordering: true, isFiltering: false, isAdjusting: false,
        selected: 0,
        frames: [ Frame(
            image: UIImage(imageLiteralResourceName: "placeholder"), transform: UIImage(imageLiteralResourceName: "placeholder"),
            width: 50, height: 70, border: 0.05, bordered: true
        )]
    )
    
    var scene: SCNScene? {
        let scene = SCNScene()
        let node = SCNNode(geometry: SCNPlane(width: 1, height: 1))
        node.geometry?.firstMaterial?.diffuse.contents = data.frames[data.selected].transform
        node.scale = SCNVector3(
            Float(data.frames[data.selected].width/100),
            Float(data.frames[data.selected].height/100),
            1
        )
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
                width: 50, height: 70,  border: 0.05, bordered: true
            ),
            at: 0
        )
        data.selected = 0
        transformImage()
    }
    
    func removeImage() {
        data.frames.remove(at: data.selected)
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
        
        if data.frames[data.selected].bordered {
            UIColor.white.setFill()
            UIRectFill(CGRect(
                x: 0, y: 0,
                width: canvas.width,
                height: canvas.height
            ))
        }
        
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
