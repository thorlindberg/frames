import SwiftUI
import SceneKit
import Foundation
import ARKit

struct Augment: View {
    
    @ObservedObject var model: Data
    @State var reload: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if !reload {
                    NavigationIndicator(model: model)
                        .ignoresSafeArea()
                        .onAppear { model.data.isAugmented = false }
                    if !model.data.isAugmented {
                        Rectangle()
                            .ignoresSafeArea()
                            .opacity(model.data.isAugmented ? 0 : 0.5)
                        VStack {
                            HStack {
                                RoundedRectangle(cornerRadius: 100)
                                    .frame(height: 5)
                                Text("Top of wall")
                                    .frame(width: 100)
                                RoundedRectangle(cornerRadius: 100)
                                    .frame(height: 5)
                            }
                            Spacer()
                            HStack {
                                RoundedRectangle(cornerRadius: 100)
                                    .frame(height: 5)
                                Text("Bottom of wall")
                                    .frame(width: 125)
                                RoundedRectangle(cornerRadius: 100)
                                    .frame(height: 5)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(30)
                    }
                    Image(uiImage: model.data.frames[model.data.selected].transform)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(model.data.isAugmented ? 70 : 50)
                        .opacity(model.data.isAugmented ? 0 : 0.5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Augmented Reality")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        model.data.isAugmenting.toggle()
                    }) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        reload.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                reload.toggle()
                            }
                        }
                    }) {
                        Text("Reload")
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

// resource: https://developer.apple.com/documentation/arkit/content_anchors/tracking_and_visualizing_planes
// resource: https://ttt.studio/blog/a-workaround-for-the-limitations-of-arkit-2/
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
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

            // let width = CGFloat(planeAnchor.extent.x)
            // let height = CGFloat(planeAnchor.extent.z)
            // if width < model.data.frames[model.data.selected].transform.size.width/1000 || height < model.data.frames[model.data.selected].transform.size.height/1000 { return }
            
            let imageHolder = SCNNode(geometry: SCNPlane(width: 1, height: 1))
            imageHolder.scale = SCNVector3(
                Float(model.data.frames[model.data.selected].transform.size.width/1000),
                Float(model.data.frames[model.data.selected].transform.size.height/1000),
                1
            )
            imageHolder.eulerAngles.x = -.pi/2
            imageHolder.geometry?.firstMaterial?.diffuse.contents = model.data.frames[model.data.selected].transform
            
            node.addChildNode(imageHolder)
            withAnimation { model.data.isAugmented = true }
            
        }

    }
    
}
