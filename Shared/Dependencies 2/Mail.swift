// source: https://dev.to/tranthanhvu/how-to-send-emails-in-swiftui-1ail

import SwiftUI
import MessageUI

class EmailHelper: NSObject {
    /// singleton
    static let shared = EmailHelper()
    private override init() {}
}

extension EmailHelper {
    
    /// Remember to add the below code to Info.plist
    ///    <key>LSApplicationQueriesSchemes</key>
    ///    <array>
    ///       <string>googlegmail</string>
    ///    </array>
    func send(subject: String, body: String, to: [String]) {
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        if !MFMailComposeViewController.canSendMail() {
            let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let mails = to.joined(separator: ",")
            
            let alert = UIAlertController(title: "Can't send feedback", message: "", preferredStyle: .actionSheet)
            
            var haveExternalMailbox = false
            
            if let defaultUrl = URL(string: "mailto:\(mails)?subject=\(subjectEncoded)&body=\(bodyEncoded)"),
               UIApplication.shared.canOpenURL(defaultUrl) {
                haveExternalMailbox = true
                alert.addAction(UIAlertAction(title: "Mail", style: .default, handler: { (action) in
                    UIApplication.shared.open(defaultUrl)
                }))
            }
            
            if let gmailUrl = URL(string: "googlegmail://co?to=\(mails)&subject=\(subjectEncoded)&body=\(bodyEncoded)"),
               UIApplication.shared.canOpenURL(gmailUrl) {
                haveExternalMailbox = true
                alert.addAction(UIAlertAction(title: "Gmail", style: .default, handler: { (action) in
                    UIApplication.shared.open(gmailUrl)
                }))
            }
            
            if haveExternalMailbox {
                alert.message = "Would you like to open an external mailbox?"
            } else {
                alert.message = "Add a mail account to send feedback"
                
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settingsUrl) {
                    alert.addAction(UIAlertAction(title: "Open Settings App", style: .default, handler: { (action) in
                        UIApplication.shared.open(settingsUrl)
                    }))
                }
            }
            
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
            return
        }
        
        let mailCompose = MFMailComposeViewController()
        mailCompose.setSubject(subject)
        mailCompose.setMessageBody(body, isHTML: false)
        mailCompose.setToRecipients(to)
        mailCompose.mailComposeDelegate = self
        
        viewController.present(mailCompose, animated: true, completion: nil)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension EmailHelper: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}