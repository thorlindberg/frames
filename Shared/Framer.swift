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

struct Framer: View {
    
    @Binding var data: Data.Format
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                if data.isResizing {
                    Picker(selection: $data.frameSize, label: Text("")) {
                        switch data.orientation {
                            case "horizontal": ForEach(data.horizontals, id: \.self) { Text("\($0) cm").tag($0) }
                            case "quadrant": ForEach(data.quadrants, id: \.self) { Text("\($0) cm").tag($0) }
                            default: ForEach(data.verticals, id: \.self) { Text("\($0) cm").tag($0) }
                        }
                    }
                } else {
                    ForEach(viewModel.imageArray, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                            .shadow(
                                color: Color.black.opacity(0.1),
                                radius: 10, x: 0, y: 0
                            )
                            .padding(50)
                            .contextMenu {
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
            .navigationBarTitle("Frames")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button(action: {
                        data.isImporting.toggle()
                    }) {
                        Image(systemName: "photo")
                    }
                    Button(action: {
                        UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController?
                            .present(viewModel.getDocumentCameraViewController(), animated: true, completion: nil)
                    }) {
                        Image(systemName: "viewfinder")
                    }
                }
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button(action: {
                        data.isResizing.toggle()
                    }) {
                        Image(systemName: "aspectratio")
                    }
                    Button(action: {
                        //
                    }) {
                        Image(systemName: "move.3d")
                    }
                }
            }
            .sheet(isPresented: $data.firstLaunch) {
                VStack(spacing: 25) {
                    Text("Welcome!")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                    Spacer()
                    Text("1. Scan/select image for framing")
                    Divider().padding(.horizontal, 60)
                    Text("2. Choose real-world frame size")
                    Divider().padding(.horizontal, 60)
                    Text("2. Preview framed image in AR")
                    Spacer()
                    Button(action: {
                        data.firstLaunch.toggle()
                    }) {
                        Text("I'm ready to rock 🤟")
                    }
                }
                .padding(.vertical, 100)
            }
        }
    }
    
}
