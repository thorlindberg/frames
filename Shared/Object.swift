import SwiftUI
import SceneKit

struct Object: View {
    
    @ObservedObject var model: Data
    
    // reference: https://developer.apple.com/documentation/arkit/arscnview/providing_3d_virtual_content_with_scenekit?language=objc
    // source: https://stackoverflow.com/questions/49353131/how-to-add-an-image-to-an-arscnscene-in-swift
    
    var object: some View {
        SceneView(scene: model.scene, options: [.allowsCameraControl])
    }
    
    var body: some View {
        NavigationView {
            object
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("3D object")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            model.data.isModelled.toggle()
                        }) {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            UIImageWriteToSavedPhotosAlbum(object.snapshot(), nil, nil, nil)
                        }) {
                            Text("Save")
                        }
                    }
                }
        }
    }
    
}

struct Object_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Object(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
