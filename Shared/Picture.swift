import SwiftUI

struct Picture: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        VStack(alignment: .center) {
            if model.data.image == nil {
                Image(systemName: "photo")
                    .font(.system(size: 200))
                    .opacity(0.1)
            } else {
                Image(uiImage: model.data.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(50)
            }
        }
    }
    
}
