import SwiftUI
import SceneKit
import VisionKit
import AVFoundation

final class Model: NSObject, ObservableObject {
    
    @Published var data: Format = Format()
    
    struct Format: Hashable {
        var isImporting: Bool = false
        var isCapturing: Bool = false
        var isPlaced: Bool = false
        var isAugmenting: Bool = false
        var isFlashlight: Bool = false
        var isBlurred: Bool = true
        var dimension: String = "width"
        var alignment: String = "none"
        var image: UIImage = UIImage(named: "sample")!
        var width: CGFloat = 50
        var height: CGFloat = 70
        var border: CGFloat = 0.05
        var frame: UIImage {

            // set frame size
            let canvas = CGSize(
                width: image.size.width,
                height: image.size.width*(height/width)
            )
            
            // begin image
            UIGraphicsBeginImageContextWithOptions(canvas, false, CGFloat(0))
            
            // set frame front color
            UIColor.white.setFill()
            UIRectFill(
                CGRect(
                    x: 0, y: 0,
                    width: canvas.width, height: canvas.height
                )
            )
            
            // set border size
            let border = canvas.width * border / 2
            
            // fill with gray
            UIColor.lightGray.setFill()
            UIRectFill(
                CGRect(
                    x: border, y: border,
                    width: canvas.width - border * 2, height: canvas.height - border * 2
                )
            )
            
            // set image size
            var imageSize: CGRect {
                if image.size.height > canvas.height {
                    return CGRect(
                        x: border + (canvas.width - canvas.height*(image.size.width/image.size.height)) / 2,
                        y: border,
                        width: canvas.height * (image.size.width/image.size.height) - border * 2,
                        height: canvas.height - border * 2
                    )
                } else {
                    return CGRect(
                        x: border,
                        y: border + (canvas.height - canvas.width*(image.size.height/image.size.width)) / 2,
                        width: canvas.width - border * 2,
                        height: canvas.width * (image.size.height/image.size.width) - border * 2
                    )
                }
            }
            
            // draw image on frame
            image.draw(in: imageSize)
            
            // end image
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // update transformed image
            if let newImage = newImage {
                return newImage
            } else {
                return self.image
            }
            
        }
        var scene: SCNScene? {
            
            // create scene and box
            let scene = SCNScene()
            let node = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 0.02, chamferRadius: 0))
            
            // define materials
            let front = SCNMaterial()
            front.diffuse.contents = frame
            
            let frame = SCNMaterial()
            frame.diffuse.contents = UIColor.white
            
            // add materials to sides
            node.geometry?.materials = [front, frame, frame, frame, frame, frame]
            
            // frame size
            node.scale = SCNVector3(
                Float(self.width/100),
                Float(self.height/100),
                1
            )
            
            // rotate frame
            node.rotation = SCNVector4Make(1, 0, 0, -(.pi / 2))
            
            // add frame to scene
            scene.rootNode.addChildNode(node)
            
            return scene
            
        }
    }
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
    }
    
    // source: https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    
    func writeScene() {
        let scene = data.scene
        let url = getDocumentsDirectory().appendingPathComponent("frame.scn")
        scene!.write(to: url, options: nil, delegate: nil, progressHandler: nil)
    }
    
}

func getDocumentsDirectory() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}

extension Model: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for i in 0..<scan.pageCount {
            data.image = scan.imageOfPage(at:i)
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

// source: https://www.hackingwithswift.com/books/ios-swiftui/importing-an-image-into-swiftui-using-uiimagepickercontroller

struct ImagePicker: UIViewControllerRepresentable {
    
    @ObservedObject var model: Model
    var type: String
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if type == "import" {
            picker.sourceType = .photoLibrary
        }
        if type == "capture" {
            picker.sourceType = .camera
        }
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
                parent.model.data.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
}
