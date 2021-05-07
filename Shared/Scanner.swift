/*
struct Scanner: View {
    
    @Binding var data: Data.Format
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
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
            .navigationTitle("Vision kit Demo")
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
    }
    
}
*/
