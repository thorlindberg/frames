import SwiftUI
import VisionKit

final class Data: NSObject, ObservableObject {
    
    struct Format: Hashable {
        var firstLaunch: Bool
        var isPresented: Bool
        var isImporting: Bool
        var isAdjusting: Bool
        var image: UIImage?
        var orientation: String
        var aspectratio: String
        var horizontals: [String]
        var verticals: [String]
        var quadrants: [String]
        var errorMessage: String?
    }
    
    @Published var data: Format = Format(
        firstLaunch: true, // replace with Bool on whether device has launched the app before!
        isPresented: false,
        isImporting: false,
        isAdjusting: false,
        orientation: "vertical",
        aspectratio: "",
        horizontals: ["18x13", "20x15", "30x21", "40x30", "45x30", "50x40", "60x45", "70x50", "80x60", "90x60", "100x70"],
        verticals: ["13x18", "15x20", "21x30", "30x40", "30x45", "40x50", "45x60", "50x70", "60x80", "60x90", "70x100"],
        quadrants: ["30x30", "50x50", "70x70"]
    )
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
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
            data.image = scan.imageOfPage(at:i)
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    
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
            model.data.image = uiImage
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
