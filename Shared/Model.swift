import SwiftUI
import SceneKit
import VisionKit
import AVFoundation

final class Model: NSObject, ObservableObject {
    
    @Published var data: Format = Format()
    
    struct Format: Hashable {
        var welcome: Bool = !UserDefaults.standard.bool(forKey: "v1.0")
        var guide: String = ""
        var isBrowsing: Bool = false
        var isImporting: Bool = false
        var isCapturing: Bool = false
        var isAugmenting: Bool = false
        var isFlashlight: Bool = false
        var selected: Int = 0
        var frames: [Frame] = [
            Frame(image: UIImage(imageLiteralResourceName: "sample")),
            Frame(image: UIImage(imageLiteralResourceName: "sample2"))
        ]
    }
    
    struct Frame: Hashable {
        var image: UIImage
        var width: CGFloat = 60
        var height: CGFloat = 90
        var border: CGFloat = 0.05
        var material: UIImage = UIImage(named: "material_oak")!
        var filter: String = ""
        var framed: UIImage {
            
            // filter image
            var image: UIImage {
                switch filter {
                    case "noir":
                        return filterImage(image: self.image, filter: "noir")
                    case "mono":
                        return filterImage(image: self.image, filter: "mono")
                    case "invert":
                        return filterImage(image: self.image, filter: "invert")
                    default:
                        return self.image
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
    }
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
    }
    
    func addImage(image: UIImage) {
        data.frames.insert(Frame(image: image), at: 0)
    }
    
    func removeImage(index: Int) {
        data.frames.remove(at: index)
    }
    
}

func filterImage(image: UIImage, filter: String) -> UIImage {
    var effect: CIFilter? {
        switch filter {
            case "noir":
                return CIFilter(name: "CIPhotoEffectNoir")
            case "mono":
                return CIFilter(name: "CIPhotoEffectNoir")
            case "invert":
                return CIFilter(name: "CIColorInvert")
            default:
                return nil
        }
    }
    if let effect = effect {
        let context = CIContext(options: nil)
        effect.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        if let output = effect.outputImage, let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }
    }
    return image
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

struct Model_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
