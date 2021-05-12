import SwiftUI
import SceneKit
import Foundation
import ARKit

struct Reality: View {
    
    @ObservedObject var model: Data
    
    var realityView: some View {
        ARQuickLookView(model: model)
    }
    
    var body: some View {
        NavigationView {
            realityView
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("AR QuickLook")
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
                            UIImageWriteToSavedPhotosAlbum(realityView.snapshot(), nil, nil, nil)
                        }) {
                            Text("Save")
                        }
                    }
                }
        }
    }
    
}

struct Reality_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}

struct ARQuickLookView: UIViewControllerRepresentable {
    
    @ObservedObject var model: Data
    
    var allowScaling: Bool = true
    
    func makeCoordinator() -> ARQuickLookView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ controller: QLPreviewController, context: Context) {
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        
        let parent: ARQuickLookView
        
        init(_ parent: ARQuickLookView) {
            self.parent = parent
            super.init()
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            let item = ARQuickLookPreviewItem(fileAt: parent.model.objectPath())
            item.allowsContentScaling = parent.allowScaling
            return item
        }
        
    }
    
}
