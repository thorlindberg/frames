import SwiftUI
import SceneKit
import SceneKit.ModelIO
import VisionKit
import AVFoundation

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
        var transform: UIImage
        var width: CGFloat
        var height: CGFloat
        var bordered: Bool
        var filled: Bool
        var rotation: CGFloat
    }
    
    @Published var data: Format = Format(
        firstLaunch: !UserDefaults.standard.bool(forKey: "hasLaunched"),
        isAction: false, isImporting: false, isAugmenting: false, isAugmented: false, isAdjusting: false, selected: 0,
        frames: [ Frame(
            image: UIImage(imageLiteralResourceName: "placeholder"), transform: UIImage(imageLiteralResourceName: "placeholder"),
            width: 50, height: 70, bordered: true, filled: false, rotation: 0
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
    
    /*
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
    */
    
    func addImage(image: UIImage) {
        data.frames.insert(
            Frame(
                image: image, transform: image,
                width: 50, height: 70,
                bordered: true, filled: false,
                rotation: 0
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
        
        // set frame size and aspect ratio
        let imageSize = CGSize(
            width: data.frames[data.selected].transform.size.width,
            height: data.frames[data.selected].transform.size.width*(data.frames[data.selected].height/data.frames[data.selected].width)
        )
        
        var aspectRatio = CGSize(
            width: data.frames[data.selected].transform.size.width,
            height: data.frames[data.selected].transform.size.height
        )
        
        // begin transformation
        UIGraphicsBeginImageContextWithOptions(imageSize, false, CGFloat(0))
        let context = UIGraphicsGetCurrentContext()!
        
        if data.frames[data.selected].bordered {
            UIColor.white.setFill()
            UIRectFill(CGRect(
                x: 0, y: 0,
                width: imageSize.width,
                height: imageSize.height
            ))
        }
        
        if data.frames[data.selected].filled {
            aspectRatio = imageSize
        }
        
        if data.frames[data.selected].rotation != 0 {
            
            // move origin to middle
            context.translateBy(x: imageSize.width/2, y: imageSize.height/2)
            
            // rotate around middle
            context.rotate(by: data.frames[data.selected].rotation)
            
            // draw the image at its center
            data.frames[data.selected].transform.draw(in: CGRect(
                x: -imageSize.width/2,
                y: -imageSize.height/2,
                width: imageSize.width,
                height: imageSize.height
            ))
            
        }
        
        data.frames[data.selected].transform.draw(in: AVMakeRect(aspectRatio: aspectRatio, insideRect: CGRect(
            x: data.frames[data.selected].bordered ? imageSize.width/20 : 0,
            y: data.frames[data.selected].bordered ? imageSize.width/20 : 0,
            width: data.frames[data.selected].bordered ? imageSize.width-imageSize.width/10 : imageSize.width,
            height: data.frames[data.selected].bordered ? imageSize.height-imageSize.width/10 : imageSize.height
        )))
        
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
