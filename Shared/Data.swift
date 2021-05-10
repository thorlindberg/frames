import SwiftUI
import VisionKit
import QuickLook
import ARKit

final class Data: NSObject, ObservableObject {
    
    struct Format: Hashable {
        var firstLaunch: Bool
        var isImporting: Bool
        var isAugmenting: Bool
        var isAdjusting: Bool
        var frames: [Frame]
        var selected: Int
        var errorMessage: String?
    }
    
    struct Frame: Hashable {
        var image: UIImage
        var width: CGFloat
        var height: CGFloat
        var bordered: Bool
        var filled: Bool
    }
    
    @Published var data: Format = Format(
        firstLaunch: !UserDefaults.standard.bool(forKey: "hasLaunched"),
        isImporting: false,
        isAugmenting: false,
        isAdjusting: false,
        frames: [Frame(image: UIImage(imageLiteralResourceName: "placeholder"), width: 50, height: 50, bordered: true, filled: false)],
        selected: 0
    )
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
    }
    
    func removeImage(item: UIImage) {
        if data.frames.count - 1 == 1 {
            data.selected = 0
        } else {
            data.selected = data.selected - 1
        }
        data.frames.removeAll{$0.image == item}
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
            data.frames.insert(Frame(image: scan.imageOfPage(at:i), width: 50, height: 50, bordered: true, filled: false), at: 0)
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
            model.data.frames.insert(Data.Frame(image: uiImage, width: 50, height: 50, bordered: true, filled: false), at: 0)
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

struct ARQuickLookView: UIViewControllerRepresentable {
    
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
        private lazy var fileURL: URL = Bundle.main.url(forResource: "frame", withExtension: "gltf")!
        
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
            guard let fileURL = Bundle.main.url(forResource: "frame", withExtension: "gltf") else {
                fatalError("Unable to load gLTF from main bundle")
            }
            
            let item = ARQuickLookPreviewItem(fileAt: fileURL)
            item.allowsContentScaling = parent.allowScaling
            return item
        }
        
    }
    
}
