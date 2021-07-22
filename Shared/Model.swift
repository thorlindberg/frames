import SwiftUI
import SceneKit
import VisionKit
import AVFoundation

final class Model: NSObject, ObservableObject {
    
    @Published var data: Format = Format()
    
    struct Format: Hashable {
        var welcome: Bool = !UserDefaults.standard.bool(forKey: "v1.0")
        var guide: String = ""
        var reload: Bool = false
        var isEditing: Bool = false
        var isImporting: Bool = false
        var isCapturing: Bool = false
        var isAugmenting: Bool = false
        var isFlashlight: Bool = false
        var selected: Int = 0
        var frames: [Frame] = [Frame(source: UIImage(imageLiteralResourceName: "sample"))]
        var camera: SCNNode? {
            let node = SCNNode()
            node.camera = SCNCamera()
            node.position = SCNVector3Make(0, 0, 1.3)
            return node
        }
    }
    
    struct Frame: Hashable {
        var colorscheme: ColorScheme?
        var source: UIImage
        var width: CGFloat = 60
        var height: CGFloat = 90
        var border: CGFloat = 0.05
        var material: UIImage = UIImage(named: "material_oak")!
        var filter: String = "original"
        var image: [String:UIImage] {
            var images: [String:UIImage] = [:]
            for name in ["original", "noir", "mono", "invert"] {
                var image = source
                var filter: CIFilter? {
                    switch name {
                        case "noir":
                            return CIFilter(name: "CIPhotoEffectNoir")!
                        case "mono":
                            return CIFilter(name: "CIPhotoEffectMono")!
                        case "invert":
                            return CIFilter(name: "CIColorInvert")!
                        default:
                            return nil
                    }
                }
                if let filter = filter {
                    let context = CIContext(options: nil)
                    filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
                    if let output = filter.outputImage,
                        let cgImage = context.createCGImage(output, from: output.extent) {
                        image = UIImage(cgImage: cgImage)
                    }
                }
                images[name] = image
            }
            return images
        }
        var framed: UIImage {
            
            // filter image
            var image: UIImage {
                switch filter {
                    case "noir":
                        return self.image["noir"]!
                    case "mono":
                        return self.image["mono"]!
                    case "invert":
                        return self.image["invert"]!
                    default:
                        return self.image["original"]!
                }
            }
            
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
            let border = canvas.width * border / 2
            
            // fill with dominant color in image
            image.averageColor!.setFill()
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
            return newImage!
            
        }
        var model: SCNScene? {
            
            // create scene and box
            let scene = SCNScene()
            let node = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 0.02, chamferRadius: 0))
            
            // set scene background
            scene.background.contents = colorscheme == .dark ? UIColor.systemGray6 : UIColor.white
            
            // define materials
            let front = SCNMaterial()
            front.diffuse.contents = framed
            
            let frame = SCNMaterial()
            frame.diffuse.contents = material
            frame.diffuse.wrapT = SCNWrapMode.repeat
            frame.diffuse.wrapS = SCNWrapMode.repeat
            
            // add materials to sides
            node.geometry?.materials = [front, frame, frame, frame, frame, frame]
            
            // frame size
            node.scale = SCNVector3(
                Float(width/100),
                Float(height/100),
                1
            )
            
            // rotate frame
            node.rotation = SCNVector4(1, 0, 0, 350 * Double.pi / 180)
            
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
        data.frames.insert(Frame(source: image), at: 0)
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

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

// source: https://stackoverflow.com/a/60939207/15072454

extension UIApplication {
    func visibleViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return nil }
        guard let rootViewController = window.rootViewController else { return nil }
        return UIApplication.getVisibleViewControllerFrom(vc: rootViewController)
    }
    private static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return UIApplication.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return UIApplication.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIApplication.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

struct DisableModalDismiss: ViewModifier {
    let disabled: Bool
    func body(content: Content) -> some View {
        disableModalDismiss()
        return AnyView(content)
    }
    func disableModalDismiss() {
        guard let visibleController = UIApplication.shared.visibleViewController() else { return }
        visibleController.isModalInPresentation = disabled
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
