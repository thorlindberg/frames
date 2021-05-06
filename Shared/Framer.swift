import SwiftUI

struct Framer: View {
    
    @Binding var data: Data.Format
    
    var body: some View {
        VStack(alignment: .center) {
            Image("poster")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 10, x: 0, y: 0
                )
            Spacer()
            Picker(selection: $data.orientation, label: Text("")) {
                Text("Vertical").tag("vertical")
                Text("Horizontal").tag("horizontal")
                Text("Quadrant").tag("quadrant")
            }
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
            Picker(selection: $data.frameSize, label: Text("")) {
                switch data.orientation {
                    case "horizontal": ForEach(data.horizontals, id: \.self) { Text("\($0) cm").tag($0) }
                    case "quadrant": ForEach(data.quadrants, id: \.self) { Text("\($0) cm").tag($0) }
                    default: ForEach(data.verticals, id: \.self) { Text("\($0) cm").tag($0) }
                }
            }
            HStack {
                Button(action: {
                    data.isScanning.toggle()
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                }
                Spacer()
                Button(action: {
                    //
                }) {
                    Text("View in AR")
                }
            }
        }
        .padding()
    }
    
}
