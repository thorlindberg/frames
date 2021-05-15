import SwiftUI
import SceneKit
import SceneKit.ModelIO
import VisionKit

final class Data: NSObject, ObservableObject {
    
    struct Format: Hashable {
        var firstLaunch: Bool
        var isAction: Bool
        var isImporting: Bool
        var isAugmenting: Bool
        var isAugmented: Bool
        var isAdjusting: Bool
        var selected: Int
        var frames: [Frame]
    }
    
    struct Frame: Hashable {
        var image: UIImage
        var width: CGFloat
        var height: CGFloat
        var bordered: Bool
        var filled: Bool
        var colored: Bool
        var brightened: Bool
        var inverted: Bool
        var rotated: Double
    }
    
    @Published var data: Format = Format(
        firstLaunch: !UserDefaults.standard.bool(forKey: "hasLaunched"),
        isAction: false, isImporting: false, isAugmenting: false, isAugmented: false, isAdjusting: false, selected: 0,
        frames: [ Frame(
            image: UIImage(imageLiteralResourceName: "placeholder"),
            width: 50, height: 50, bordered: true, filled: false, colored: true, brightened: false, inverted: false, rotated: 0
        )]
    )
    
    var scene: SCNScene? {
        let scene = SCNScene()
        let node = SCNNode(geometry: SCNPlane(width: 1, height: 1))
        node.geometry?.firstMaterial?.diffuse.contents = data.frames[data.selected].image
        node.scale = SCNVector3(
            Float(data.frames[data.selected].image.size.width/1000),
            Float(data.frames[data.selected].image.size.height/1000),
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
    
    func objectPath() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("object.scn")
    }
    
    func writeObject() {
        
        // reference: https://stackoverflow.com/questions/64037121/how-to-programmatically-export-3d-mesh-as-usdz-using-modelio
        // reference: https://stackoverflow.com/questions/61452732/usdz-export-from-scenekit-results-in-dull-models
        // source: https://stackoverflow.com/questions/66473004/export-scnscene-as-obj-in-scenekit
        
        /*
        do {
            try MDLAsset(scnScene: scene!).export(to: objectPath())
        } catch {
            return
        }
        */
 
        scene?.write(to: objectPath(), delegate: nil)
        
    }
    
    func addImage(image: UIImage) {
        data.frames.insert(
            Frame(image: image, width: 50, height: 50, bordered: true, filled: false, colored: true, brightened: false, inverted: false, rotated: 0),
            at: 0
        )
        data.selected = 0
    }
    
    func removeImage() {
        data.frames.remove(at: data.selected)
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
