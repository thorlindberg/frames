import SwiftUI
import SceneKit
import Foundation
import UIKit
import ARKit

// resource: https://developer.apple.com/documentation/arkit/content_anchors/tracking_and_visualizing_planes
// resource: https://ttt.studio/blog/a-workaround-for-the-limitations-of-arkit-2/
// source: https://blog.devgenius.io/implementing-ar-in-swiftui-without-storyboards-ec529ace7ab2

struct ARViewContainer: UIViewControllerRepresentable {
    
    @ObservedObject var model: Model
    
    typealias UIViewControllerType = ARView
    
    func makeUIViewController(context: Context) -> ARView {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewcontroller = storyboard.instantiateViewController(identifier: "Main") as? ARView {
            viewcontroller.model = model
            return viewcontroller
        } else {
            return storyboard.instantiateViewController(identifier: "Main") as! ARView
        }
    }
    func updateUIViewController(_ uiViewController: ARViewContainer.UIViewControllerType, context: UIViewControllerRepresentableContext<ARViewContainer>) { }
    
}

class ARView: UIViewController, ARSCNViewDelegate {
    
    // MARK: Object model
    
    var model: Model!
    
    // MARK: - Initalisation
    
    init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: IBOutlets
    
    @IBOutlet var sceneView: VirtualObjectARView!
    
    @IBOutlet weak var addObjectButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var upperControlsView: UIView!

    // MARK: - UI Elements
    
    let coachingOverlay = ARCoachingOverlayView()
    
    var focusSquare = FocusSquare()
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// The view controller that displays the virtual object selection menu.
    var objectsViewController: VirtualObjectSelectionViewController?
    
    // MARK: - ARKit Configuration Properties
    
    /// A type which manages gesture manipulation of virtual content in the scene.
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView, viewController: self)
    
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Set up coaching overlay.
        setupCoachingOverlay()

        // Set up scene content.
        sceneView.scene.rootNode.addChildNode(focusSquare)

        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showVirtualObjectSelectionViewController))
        // Set the delegate to ensure this gesture is only used when there are no virtual objects in the scene.
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true

        // Start the `ARSession`.
        resetTracking()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        session.pause()
    }

    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
        virtualObjectInteraction.selectedObject = nil
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        statusViewController.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
    }

    // MARK: - Focus Square

    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible || coachingOverlay.isActive {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
            statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
        }
        
        // Perform ray casting only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let query = sceneView.getRaycastQuery(),
            let result = sceneView.castRay(for: query).first {
            
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(raycastResult: result, camera: camera)
            }
            if !coachingOverlay.isActive {
                addObjectButton.isHidden = false
            }
            statusViewController.cancelScheduledMessage(for: .focusSquare)
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            addObjectButton.isHidden = true
            objectsViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // WARNING: old code

    /*
    init(_ model: Model) {
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
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
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
        
        guard anchor is ARPlaneAnchor else { return }

        // let width = CGFloat(planeAnchor.extent.x)
        // let height = CGFloat(planeAnchor.extent.z)
        // if width < model.data.frames[model.data.selected].framed.size.width/1000 || height < model.data.frames[model.data.selected].framed.size.height/1000 { return }
        
        let imageHolder = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 0.02, chamferRadius: 0))
        imageHolder.eulerAngles.x = -.pi/2
        
        // define materials
        let front = SCNMaterial()
        front.diffuse.contents = model.data.frames[model.data.selected].framed
        
        let frame = SCNMaterial()
        frame.diffuse.contents = model.data.frames[model.data.selected].material
        frame.diffuse.wrapT = SCNWrapMode.repeat
        frame.diffuse.wrapS = SCNWrapMode.repeat
        
        // add materials to sides
        imageHolder.geometry?.materials = [front, frame, frame, frame, frame, frame]
        
        // frame size
        imageHolder.scale = SCNVector3(
            Float(model.data.frames[model.data.selected].width / 100),
            Float(model.data.frames[model.data.selected].height / 100),
            1
        )
        
        // add frame to scene
        node.addChildNode(imageHolder)

    }
    */
    
}
