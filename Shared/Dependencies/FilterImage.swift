import SwiftUI

func filterImage(filter: CIFilter?, image: UIImage) -> UIImage {
    var image = image
    if let filter = filter {
        let context = CIContext(options: nil)
        filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        if let output = filter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            image = UIImage(cgImage: cgImage)
        }
    }
    return image
}
