//  Created by Thor Lindberg on 29/07/2021.

import SwiftUI

class Helper {
    class func alertMessage(title: String, message: String, image: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        imageView.image = UIImage(named: image)
        alertVC.view.addSubview(imageView)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in }
        alertVC.addAction(okAction)
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
}

struct ImageAlert: View {
    var body: some View {
        Button(action: {
            Helper.alertMessage(
                title: "Attention!",
                message: "You're being show an alert",
                image: "sample" // replace with the name of an image from Assets.xcassets
            )
        }) {
            Text("Show Alert")
        }
    }
}

struct ImageAlert_Previews: PreviewProvider {
    static var previews: some View {
        ImageAlert()
    }
}
