import SwiftUI
import SceneKit

struct Augment: View {
    
    @ObservedObject var model: Data
    
    var scene: SCNScene? {
        let myScene = SCNScene()
        let node = SCNNode(geometry: SCNPlane())
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(imageLiteralResourceName: "placeholder")
        myScene.rootNode.addChildNode(node)
        return myScene
    }
    
    var body: some View {
        NavigationView {
            SceneView(scene: scene)
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
            Content(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
