import SwiftUI
import VisionKit
import QuickLook
import SceneKit
import ARKit

final class Data: NSObject, ObservableObject {
    
    struct Format: Hashable {
        var firstLaunch: Bool
        var isImporting: Bool
        var isAugmenting: Bool
        var isAdjusting: Bool
        var frames: [Frame]
        var selected: Int
        var augment: Augment?
        var errorMessage: String?
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
    
    struct Augment: Hashable {
        var scene: SCNScene
        var node: SCNNode
    }
    
    @Published var data: Format = Format(
        firstLaunch: !UserDefaults.standard.bool(forKey: "hasLaunched"),
        isImporting: false,
        isAugmenting: false,
        isAdjusting: false,
        frames: [
            Frame(
                image: UIImage(imageLiteralResourceName: "placeholder"),
                width: 50, height: 50, bordered: true, filled: false, colored: true, brightened: false, inverted: false, rotated: 0
            ),
            Frame(
                image: UIImage(imageLiteralResourceName: "sample1"),
                width: 50, height: 50, bordered: true, filled: false, colored: true, brightened: false, inverted: false, rotated: 0
            ),
            Frame(
                image: UIImage(imageLiteralResourceName: "sample2"),
                width: 50, height: 50, bordered: true, filled: false, colored: true, brightened: false, inverted: false, rotated: 0
            )
        ],
        selected: 0
        // augment: Augment(scene: SCNScene(named: "Models.scnassets/Avatar.scn")!, node: SCNNode())
    )
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
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
        data.errorMessage = error.localizedDescription
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

/*
struct ARQuickLookView: UIViewControllerRepresentable {
    
    @ObservedObject var model: Data
    
    // reference: https://developer.apple.com/documentation/arkit/arscnview/providing_3d_virtual_content_with_scenekit?language=objc
    // source: https://stackoverflow.com/questions/49353131/how-to-add-an-image-to-an-arscnscene-in-swift
    
    // let scene = SCNNode(geometry: SCNPlane(width: model.data.frames[model.data.selected].width, height: model.data.frames[model.data.selected].height)).geometry?.firstMaterial?.diffuse.contents = model.data.frames[model.data.selected].image
    
    // source: https://developer.apple.com/forums/thread/126377
    
    var allowScaling: Bool = true
    
    func makeCoordinator() -> ARQuickLookView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ controller: QLPreviewController, context: Context) {
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        
        let parent: ARQuickLookView
        
        init(_ parent: ARQuickLookView) {
            self.parent = parent
            super.init()
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            let item = ARQuickLookPreviewItem(fileAt: parent.model.data.scene!)
            item.allowsContentScaling = parent.allowScaling
            return item
        }
        
    }
    
}
*/
