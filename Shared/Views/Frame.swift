import SwiftUI
import SceneKit

struct Frame: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        VStack(spacing: 0) {
            if model.data.frames.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "photo")
                        .opacity(0.15)
                        .font(.system(size: 150))
                    Spacer()
                }
                Spacer()
            } else {
                SceneView(scene: model.scene, options: [.allowsCameraControl])
                Adjustment(model: model)
            }
            
        }
    }
    
}

struct Frame_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
