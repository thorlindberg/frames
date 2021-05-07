import SwiftUI

struct Framer: View {
    
    @Binding var data: Data.Format
    
    var body: some View {
        NavigationView {
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
                Picker(selection: $data.frameSize, label: Text("")) {
                    switch data.orientation {
                        case "horizontal": ForEach(data.horizontals, id: \.self) { Text("\($0) cm").tag($0) }
                        case "quadrant": ForEach(data.quadrants, id: \.self) { Text("\($0) cm").tag($0) }
                        default: ForEach(data.verticals, id: \.self) { Text("\($0) cm").tag($0) }
                    }
                }
            }
            .padding()
            .actionSheet(isPresented: $data.showActions) {
                ActionSheet(title: Text("Add a picture"), buttons: [
                    .default(Text("Import")) { data.isImporting.toggle() },
                    .default(Text("Scan")) { data.isScanning.toggle() },
                    .cancel()
                ])
            }
            .navigationBarTitle("Frames")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        data.showActions.toggle()
                    }) {
                        Image(systemName: "photo")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        //
                    }) {
                        Text("AR")
                    }
                }
            }
            .sheet(isPresented: $data.firstLaunch) {
                VStack(spacing: 25) {
                    Text("Welcome!")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                    Spacer()
                    Text("1. Scan/select image for framing")
                    Divider().padding(.horizontal, 60)
                    Text("2. Choose real-world frame size")
                    Divider().padding(.horizontal, 60)
                    Text("2. Preview framed image in AR")
                    Spacer()
                    Button(action: {
                        data.firstLaunch.toggle()
                    }) {
                        Text("I'm ready to rock 🤟")
                    }
                }
                .padding(.vertical, 100)
            }
        }
    }
    
}
