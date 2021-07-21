import SwiftUI
import SceneKit
import VisionKit
import AVFoundation

final class Model: NSObject, ObservableObject {
    
    @Published var data: Format = Format()
    
    struct Format: Hashable {
        var colorscheme: ColorScheme?
        var welcome: Bool = !UserDefaults.standard.bool(forKey: "v1.0")
        var guide: String = ""
        var reload: Bool = false
        var isImporting: Bool = false
        var isCapturing: Bool = false
        var isAugmenting: Bool = false
        var isFlashlight: Bool = false
        var selected: Int = 0
        var frames: [Frame] = [
            Frame(image: UIImage(imageLiteralResourceName: "sample")),
            Frame(image: UIImage(imageLiteralResourceName: "sample2"))
        ]
        var feedback: Contact = Contact(
            category: "", issue: "", description: "", email: "", focus: "",
            invalid: false, success: false
        )
        var camera: SCNNode? {
            let node = SCNNode()
            node.camera = SCNCamera()
            node.position = SCNVector3Make(0, 0, 1.3)
            return node
        }
        var scene: SCNScene? {
            
            // create scene and box
            let scene = SCNScene()
            let node = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 0.02, chamferRadius: 0))
            
            // set scene background
            scene.background.contents = colorscheme == .dark ? UIColor.systemGray6 : UIColor.white
            
            // define materials
            let front = SCNMaterial()
            front.diffuse.contents = frames[selected].transform
            
            let frame = SCNMaterial()
            frame.diffuse.contents = frames[selected].material
            frame.diffuse.wrapT = SCNWrapMode.repeat
            frame.diffuse.wrapS = SCNWrapMode.repeat
            
            // add materials to sides
            node.geometry?.materials = [front, frame, frame, frame, frame, frame]
            
            // frame size
            node.scale = SCNVector3(
                Float(frames[selected].width/100),
                Float(frames[selected].height/100),
                1
            )
            
            // rotate frame
            node.rotation = SCNVector4(1, 0, 0, 350 * Double.pi / 180)
            
            // add frame to scene
            scene.rootNode.addChildNode(node)
            
            return scene
            
        }
    }
    
    struct Frame: Hashable {
        var image: UIImage
        var width: CGFloat = 60
        var height: CGFloat = 90
        var border: CGFloat = 0.05
        var filter: CIFilter?
        var filtered: Bool = false
        var material: UIImage = UIImage(named: "material_oak")!
        var transform: UIImage {
            
            // filter image
            let image = filtered ? filterImage(filter: filter, image: image) : image
            
            // set frame size
            let canvas = CGSize(
                width: image.size.width,
                height: image.size.width*(height/width)
            )
            
            // begin image
            UIGraphicsBeginImageContextWithOptions(canvas, false, CGFloat(0))
            
            // set frame material
            let front = CGRect(x: 0, y: 0, width: canvas.width, height: canvas.height)
            material.drawAsPattern(in: front)
            UIRectFill(front)
            
            // set border size
            let border = canvas.width*border/2
            
            // fill with dominant color in image
            image.averageColor!.setFill()
            UIRectFill(CGRect(x: border, y: border, width: canvas.width - border * 2, height: canvas.height - border * 2))
            
            // set image size
            var imageSize: CGRect {
                if image.size.height > canvas.height {
                    return CGRect(
                        x: border + (canvas.width - canvas.height*(image.size.width/image.size.height)) / 2,
                        y: border,
                        width: canvas.height*(image.size.width/image.size.height)-canvas.width*border,
                        height: canvas.height-canvas.width*border
                    )
                } else {
                    return CGRect(
                        x: border,
                        y: border + (canvas.height - canvas.width*(image.size.height/image.size.width)) / 2,
                        width: canvas.width-canvas.width*border,
                        height: canvas.width*(image.size.height/image.size.width)-canvas.width*border
                    )
                }
            }
            
            // draw image on frame
            image.draw(in: imageSize)
            
            // end image
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // update transformed image
            return newImage!
            
        }
    }
    
    struct Contact: Hashable {
        var category: String
        var issue: String
        var description: String
        var email: String
        var focus: String
        var invalid: Bool
        var success: Bool
    }
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
    }
    
    func addImage(image: UIImage) {
        data.frames.insert(Frame(image: image), at: 0)
        reloadStack()
    }
    
    func removeImage(index: Int) {
        data.frames.remove(at: index)
        reloadStack()
    }
    
    func reloadStack() {
        data.selected = 0
        data.reload = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.data.reload = false
        }
    }
    
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

struct Model_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
