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
                Text("30x50 cm").tag("30x50")
                Text("50x60 cm").tag("50x60")
                Text("50x70 cm").tag("50x70")
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
