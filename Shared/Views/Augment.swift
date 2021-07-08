import SwiftUI
import SceneKit
import Foundation
import ARKit

struct Augment: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        ARViewContainer(model: model)
            .transition(.move(edge: .bottom))
            .ignoresSafeArea()
            .onAppear { model.data.isAugmented = false }
    }
    
}

// resource: https://developer.apple.com/documentation/arkit/content_anchors/tracking_and_visualizing_planes
// resource: https://ttt.studio/blog/a-workaround-for-the-limitations-of-arkit-2/
// source: https://blog.devgenius.io/implementing-ar-in-swiftui-without-storyboards-ec529ace7ab2

struct ARViewContainer: UIViewControllerRepresentable {
    
    @ObservedObject var model: Data
    
    typealias UIViewControllerType = ARView
    
    func makeUIViewController(context: Context) -> ARView {
        return ARView(model)
    }
    func updateUIViewController(_ uiViewController:
        ARViewContainer.UIViewControllerType, context:
        UIViewControllerRepresentableContext<ARViewContainer>) { }
    
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
        
        if !model.data.isAugmented {
            
            guard anchor is ARPlaneAnchor else { return }

            // let width = CGFloat(planeAnchor.extent.x)
            // let height = CGFloat(planeAnchor.extent.z)
            // if width < model.data.frames[model.data.selected].transform.size.width/1000 || height < model.data.frames[model.data.selected].transform.size.height/1000 { return }
            
            let imageHolder = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 0.02, chamferRadius: 0))
            imageHolder.eulerAngles.x = -.pi/2
            
            // define materials
            let front = SCNMaterial()
            front.diffuse.contents = model.data.frames[model.data.selected].transform
            
            let frame = SCNMaterial()
            switch model.data.frames[model.data.selected].material {
                case "Black": frame.diffuse.contents = UIColor.black
                case "Oak": frame.diffuse.contents = UIImage(named: "material_oak")
                case "Steel": frame.diffuse.contents = UIImage(named: "material_steel")
                case "Marble": frame.diffuse.contents = UIImage(named: "material_marble")
                default: frame.diffuse.contents = UIColor.white
            }
            frame.diffuse.wrapT = SCNWrapMode.repeat
            frame.diffuse.wrapS = SCNWrapMode.repeat
            
            // add materials to sides
            imageHolder.geometry?.materials = [front, frame, frame, frame, frame, frame]
            
            // frame size
            imageHolder.scale = SCNVector3(
                Float(model.data.frames[model.data.selected].width/100),
                Float(model.data.frames[model.data.selected].height/100),
                1
            )
            
            // add frame to scene
            node.addChildNode(imageHolder)

            withAnimation { model.data.isAugmented = true }
            
        }

    }
    
}

// source: https://stackoverflow.com/questions/62388053/reset-arview-and-run-coaching-overlay-again

/*
extension ARView: ARCoachingOverlayViewDelegate {
    
    func addCoaching() {
        // Create a ARCoachingOverlayView object
        let coachingOverlay = ARCoachingOverlayView()
        // Make sure it rescales if the device orientation changes
        coachingOverlay.autoresizingMask = [
            .flexibleWidth, .flexibleHeight
        ]
        self.view.addSubview(coachingOverlay)
        // Set the Augmented Reality goal
        coachingOverlay.goal = .verticalPlane
        // Set the ARSession
        coachingOverlay.session = self.session
        // Set the delegate for any callbacks
        coachingOverlay.delegate = self
    }
    // Example callback for the delegate object
    func coachingOverlayViewDidDeactivate(
        _ coachingOverlayView: ARCoachingOverlayView
    ) {
        self.addObjectsToScene()
    }
    
}
*/

struct Augment_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
