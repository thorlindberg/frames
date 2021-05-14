import SwiftUI
import SceneKit
import Foundation
import ARKit

struct Augment: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            NavigationIndicator(model: model)
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
                            UIImageWriteToSavedPhotosAlbum(NavigationIndicator(model: model).snapshot(), nil, nil, nil)
                        }) {
                            Image(systemName: "camera")
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

// source: https://blog.devgenius.io/implementing-ar-in-swiftui-without-storyboards-ec529ace7ab2

struct NavigationIndicator: UIViewControllerRepresentable {
    
    @ObservedObject var model: Data
    
    typealias UIViewControllerType = ARView
    func makeUIViewController(context: Context) -> ARView {
        return ARView(model)
    }
    func updateUIViewController(_ uiViewController: NavigationIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<NavigationIndicator>) { }
    
}

struct ARViewIndicator: UIViewControllerRepresentable {
    
    @ObservedObject var model: Data
    
    typealias UIViewControllerType = ARView
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView(model)
    }
    func updateUIViewController(_ uiViewController:
        ARViewIndicator.UIViewControllerType, context:
        UIViewControllerRepresentableContext<ARViewIndicator>) { }
    
}

class ARView: UIViewController, ARSCNViewDelegate {
    
    @ObservedObject var model: Data

    init(_ model: Data) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var arView: ARSCNView {
        return self.view as! ARSCNView
    }
    
    override func loadView() {
        self.view = ARSCNView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.delegate = self
        arView.scene = model.scene!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        arView.session.run(configuration)
        arView.delegate = self
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    func sessionWasInterrupted(_ session: ARSession) { }
    
    func sessionInterruptionEnded(_ session: ARSession) { }
    func session(_ session: ARSession, didFailWithError error: Error) { }
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) { }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // source: https://stackoverflow.com/a/51905229/15072454

        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        let imageHolder = SCNNode(geometry: SCNPlane(width: 1, height: 1))
        imageHolder.scale = SCNVector3(
            Float(model.data.frames[model.data.selected].image.size.width/1000),
            Float(model.data.frames[model.data.selected].image.size.height/1000),
            1
        )
        imageHolder.eulerAngles.x = -.pi/2
        imageHolder.geometry?.firstMaterial?.diffuse.contents = model.data.frames[model.data.selected].image
        node.addChildNode(imageHolder)

    }
    
}
