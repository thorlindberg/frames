import SwiftUI
import VisionKit
import QuickLook
import ARKit

final class Data: NSObject, ObservableObject {
    
    struct Format: Hashable {
        var firstLaunch: Bool
        var isImporting: Bool
        var isAugmenting: Bool
        var images: [UIImage]
        var selected: Int
        var orientation: String
        var aspectratio: String
        var horizontals: [String]
        var verticals: [String]
        var quadrants: [String]
        var errorMessage: String?
    }
    
    @Published var data: Format = Format(
        firstLaunch: true, // replace with Bool on whether device has launched the app before!
        isImporting: false,
        isAugmenting: false,
        images: [UIImage(imageLiteralResourceName: "photo"), UIImage(imageLiteralResourceName: "photo2")],
        selected: 0,
        orientation: "vertical",
        aspectratio: "50x70",
        horizontals: ["18x13", "20x15", "30x21", "40x30", "45x30", "50x40", "60x45", "70x50", "80x60", "90x60", "100x70"],
        verticals: ["13x18", "15x20", "21x30", "30x40", "30x45", "40x50", "45x60", "50x70", "60x80", "60x90", "70x100"],
        quadrants: ["30x30", "50x50", "70x70"]
    )
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
    }
    
    func removeImage(item: UIImage) {
        if data.images.count - 1 == 1 {
            data.selected = 0
        } else {
            data.selected = data.selected - 1
        }
        data.images.removeAll{$0 == item}
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
            data.images.append(scan.imageOfPage(at:i))
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
            model.data.images.append(uiImage)
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
        private lazy var fileURL: URL = Bundle.main.url(forResource: "photo", withExtension: "reality")!
        
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
                fatalError("Unable to load \("photo").reality from main bundle")
            }
            
            let item = ARQuickLookPreviewItem(fileAt: fileURL)
            item.allowsContentScaling = parent.allowScaling
            return item
        }
        
    }
    
}
