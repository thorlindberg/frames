import SwiftUI

struct Adjust: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .opacity(colorScheme == .dark ? 0 : 0.07)
                if model.data.image == nil {
                    Image("photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .border(Color.white, width: 10)
                        .shadow(color: Color.black.opacity(0.1), radius: 15)
                        .padding(40)
                } else {
                    Image(uiImage: model.data.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(40)
                }
            }
            ZStack {
                Rectangle()
                    .opacity(colorScheme == .dark ? 0.07 : 0)
                Picker(selection: $model.data.aspectratio, label: Text("")) {
                    switch model.data.orientation {
                        case "vertical": ForEach(model.data.verticals, id: \.self) { Text("\($0) cm").tag($0) }
                        case "horizontal": ForEach(model.data.horizontals, id: \.self) { Text("\($0) cm").tag($0) }
                        default: ForEach(model.data.quadrants, id: \.self) { Text("\($0) cm").tag($0) }
                    }
                }
            }
            .frame(height: 220)
        }
    }
    
}
