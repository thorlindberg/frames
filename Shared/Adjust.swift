import SwiftUI

struct Adjust: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            Picker(selection: $model.data.aspectratio, label: Text("")) {
                switch model.data.orientation {
                    case "vertical": ForEach(model.data.verticals, id: \.self) { Text("\($0) cm").tag($0) }
                    case "horizontal": ForEach(model.data.horizontals, id: \.self) { Text("\($0) cm").tag($0) }
                    default: ForEach(model.data.quadrants, id: \.self) { Text("\($0) cm").tag($0) }
                }
            }
        }
    }
    
}
