import SwiftUI
import ARKit
import QuickLook

struct Augment: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            PreviewController(model: model)
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Augmented Reality")
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: {
                            model.data.isAugmenting.toggle()
                        }) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            UIImageWriteToSavedPhotosAlbum(PreviewController(model: model).snapshot(), nil, nil, nil)
                        }) {
                            Text("Save")
                        }
                    }
                }
        }
    }
    
}

struct Augment_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}

struct PreviewController: UIViewControllerRepresentable {
    
    // resources: https://developer.apple.com/forums/thread/126377
    // resource: https://lostmoa.com/blog/PreviewFilesWithQuickLookInSwiftUI/
    // source: https://github.com/LostMoa/SwiftUI-Code-Examples/blob/main/PreviewFilesWithQuickLookInSwiftUI/SwiftUIQuickLook/PreviewController.swift
    
    @ObservedObject var model: Data
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ controller: QLPreviewController, context: Context) { }

    func makeCoordinator() -> Coordinator { return Coordinator(parent: self) }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: PreviewController
        init(parent: PreviewController) { self.parent = parent }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            let item = ARQuickLookPreviewItem(fileAt: parent.model.objectPath())
            item.allowsContentScaling = true
            return item
        }
    }
}
