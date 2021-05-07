import SwiftUI
import VisionKit

final class ContentViewModel: NSObject, ObservableObject {
    @Published var errorMessage: String?
    @Published var imageArray: [UIImage] = []
    
    func getDocumentCameraViewController() -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        return vc
    }
    
    func removeImage(image: UIImage) {
        imageArray.removeAll{$0 == image}
    }
}

extension ContentViewModel: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        print("Did Finish With Scan.")
        for i in 0..<scan.pageCount {
            self.imageArray.append(scan.imageOfPage(at:i))
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

struct Scanner: View {
    
    @Binding var data: Data.Format
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                data.isScanning.toggle()
                data.image = [0] // placeholder for image data
            }) {
                Text("[SAVE SCAN]")
            }
        }
        /*
        NavigationView {
            List {
                if let error = viewModel.errorMessage {
                    Text(error)
                } else {
                    ForEach(viewModel.imageArray, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit).contextMenu {
                                Button {
                                    let items = [image]
                                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                                    UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.present(ac, animated: true)
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                Divider()
                                Button {
                                    viewModel.removeImage(image: image)
                                } label: {
                                    Label("Delete", systemImage: "delete.left")
                                }
                                
                            }
                    }
                }
            }
            .navigationTitle("Vinson kit Demo")
            .navigationBarItems(leading: Button(action: {
                let items = viewModel.imageArray
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.present(ac, animated: true)
            }, label: {
                Text("Share All Images")
            }).disabled(viewModel.imageArray.count == 0), trailing: Button(action: {
                UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?.present(viewModel.getDocumentCameraViewController(), animated: true, completion: nil)
            }, label: {
                Text("Scan New Doc")
            }))
            
        }
        */
    }
    
}
