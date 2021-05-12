import SwiftUI
import SceneKit
import Foundation
import ARKit
import QuickLook

struct Reality: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            PreviewController(model: model)
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
                            UIImageWriteToSavedPhotosAlbum(PreviewController(model: model).snapshot(), nil, nil, nil)
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

struct PreviewController: UIViewControllerRepresentable {
    
    // resource: https://lostmoa.com/blog/PreviewFilesWithQuickLookInSwiftUI/
    // source: https://github.com/LostMoa/SwiftUI-Code-Examples/blob/main/PreviewFilesWithQuickLookInSwiftUI/SwiftUIQuickLook/PreviewController.swift
    
    @ObservedObject var model: Data
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        
        let parent: PreviewController
        
        init(parent: PreviewController) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.model.objectPath()! as QLPreviewItem
        }
        
    }
}
