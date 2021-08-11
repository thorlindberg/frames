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
        var alignment: String = "none"
        var selected: Int = 0
        var frames: [Frame] = [Frame()]
    }
    
    struct Frame: Hashable {
        var image: UIImage?
        var width: CGFloat = 50
        var height: CGFloat = 70
        var border: CGFloat = 0.05
        var frame: UIImage {
            
            if let image = self.image {
                
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
                    return image
                }
                
            } else {
                
                // set frame size
                let canvas = CGSize(
                    width: width*10,
                    height: width*(height/width)*10
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
                    if height > canvas.height {
                        return CGRect(
                            x: border + (canvas.width - canvas.height*(width/height)) / 2,
                            y: border,
                            width: canvas.height * (width/height) - border * 2,
                            height: canvas.height - border * 2
                        )
                    } else {
                        return CGRect(
                            x: border,
                            y: border + (canvas.height - canvas.width*(height/width)) / 2,
                            width: canvas.width - border * 2,
                            height: canvas.width * (height/width) - border * 2
                        )
                    }
                }
                
                // end image
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                // update transformed image
                return newImage!
                
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
    
    func addImage(image: UIImage) {
        data.frames.insert(Frame(image: image), at: 1)
        data.selected = 1
        updateScenes()
    }
    
    func removeImage(index: Int) {
        data.frames.remove(at: index)
        data.selected -= 1
        updateScenes()
    }
    
    // source: https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    
    func updateScenes() {
        // delete any existing scenes
        let fileEnumerator = FileManager().enumerator(at: getDocumentsDirectory(), includingPropertiesForKeys: [])!
        for file in fileEnumerator {
            let url = file as! URL
            if url.pathExtension == "scn" {
                do {
                    try FileManager().removeItem(at: url)
                } catch {
                    print("file could not be deleted")
                }
            }
        }
        // write new scenes
        for (index, frame) in data.frames.enumerated() {
            let scene = frame.scene
            let url = getDocumentsDirectory().appendingPathComponent("frame \(index+1).scn")
            scene!.write(to: url, options: nil, delegate: nil, progressHandler: nil)
        }
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
            addImage(image: scan.imageOfPage(at:i))
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
                parent.model.addImage(image: uiImage)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
}
