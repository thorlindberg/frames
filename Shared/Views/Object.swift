import SwiftUI
import SceneKit

struct Object: View {
    
    @ObservedObject var model: Data
    @State var refresh: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if !refresh {
                    SceneView(scene: model.scene, options: [.allowsCameraControl])
                }
            }
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
                        refresh.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                refresh.toggle()
                            }
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    /*
                    Button(action: {
                        UIImageWriteToSavedPhotosAlbum(SceneView(scene: model.scene, options: [.allowsCameraControl]).snapshot(), nil, nil, nil)
                    }) {
                        Image(systemName: "camera")
                    }
                    */
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
