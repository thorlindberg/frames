import SwiftUI
import SceneKit

struct Object: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            SceneView(scene: model.scene, options: [.allowsCameraControl])
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("3D object")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            model.data.isModeling.toggle()
                        }) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            UIImageWriteToSavedPhotosAlbum(SceneView(scene: model.scene, options: [.allowsCameraControl]).snapshot(), nil, nil, nil)
                        }) {
                            Image(systemName: "camera")
                        }
                    }
                }
        }
    }
    
}

struct Object_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
