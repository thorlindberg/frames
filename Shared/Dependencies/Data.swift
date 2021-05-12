import SwiftUI
import SceneKit
import VisionKit

final class Data: NSObject, ObservableObject {
    
    struct Format: Hashable {
        var firstLaunch: Bool
        var isImporting: Bool
        var isAugmenting: Bool
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
        isImporting: false, isAugmenting: false, isAdjusting: false, selected: 0,
        frames: [ Frame(
            image: UIImage(imageLiteralResourceName: "placeholder"),
            width: 50, height: 50, bordered: true, filled: false, colored: true, brightened: false, inverted: false, rotated: 0
        )]
    )
    
    var scene: SCNScene? {
        let myScene = SCNScene()
        let imageNode = SCNNode(geometry: SCNPlane())
        imageNode.geometry?.firstMaterial?.diffuse.contents = data.frames[data.selected].image
        imageNode.scale = SCNVector3(
            Float(data.frames[data.selected].image.size.width),
            Float(data.frames[data.selected].image.size.height),
            1
        )
        myScene.rootNode.addChildNode(imageNode)
        return myScene
    }
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
    }
    
    func objectPath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("object.usdz")
    }
    
    func writeObject() {
        // reference: https://stackoverflow.com/questions/64037121/how-to-programmatically-export-3d-mesh-as-usdz-using-modelio
        scene?.write(to: objectPath(), options: nil, delegate: nil, progressHandler: nil)
    }
    
    func removeImage() {
        if data.frames.count - 1 == 1 {
            data.selected = 0
        } else {
            data.selected = data.selected - 1
        }
        data.frames.remove(at: data.selected + 1)
    }
    
    func getBundleDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
            data.frames.insert(Frame(image: scan.imageOfPage(at:i), width: 50, height: 50, bordered: true, filled: false, colored: true, brightened: false, inverted: false, rotated: 0), at: 0)
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
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let uiImage = info[.originalImage] as? UIImage {
            model.data.frames.insert(Data.Frame(image: uiImage, width: 50, height: 50, bordered: true, filled: false, colored: true, brightened: false, inverted: false, rotated: 0), at: 0)
        }
        self.presentationMode.wrappedValue.dismiss()
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
    }
    
}
