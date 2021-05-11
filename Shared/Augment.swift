import SwiftUI
import SceneKit
import QuickLook
import SceneKit
import ARKit

struct Augment: View {
    
    @ObservedObject var model: Data
    
    var scene: SCNScene? {
        let myScene = SCNScene()
        let imageNode = SCNNode(geometry: SCNPlane())
        imageNode.geometry?.firstMaterial?.diffuse.contents = model.data.frames[model.data.selected].image
        imageNode.scale = SCNVector3(Float(model.data.frames[model.data.selected].image.size.width), Float(model.data.frames[model.data.selected].image.size.height), 1)
        myScene.rootNode.addChildNode(imageNode)
        return myScene
    }
    
    var body: some View {
        NavigationView {
            SceneView(scene: scene, options: [.allowsCameraControl])
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("3D rendered object")
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button(action: {
                            model.data.isAugmenting.toggle()
                        }) {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
    
}

struct Augment_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Augment(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}

/*
struct ARQuickLookView: UIViewControllerRepresentable {
    
    @ObservedObject var model: Data
    
    // reference: https://developer.apple.com/documentation/arkit/arscnview/providing_3d_virtual_content_with_scenekit?language=objc
    // source: https://stackoverflow.com/questions/49353131/how-to-add-an-image-to-an-arscnscene-in-swift
    
    // source: https://developer.apple.com/forums/thread/126377
    
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
            let item = ARQuickLookPreviewItem(fileAt: parent.model.data.scene!)
            item.allowsContentScaling = parent.allowScaling
            return item
        }
        
    }
    
}
*/
