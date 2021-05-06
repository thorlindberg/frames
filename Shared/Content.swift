import SwiftUI

struct Content: View {
    
    @State var data: Data.Format = Data().data
    
    var body: some View {
        ZStack {
            if data.isScanning {
                Scanner(data: $data)
            } else {
                Framer(data: $data)
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

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        Content()
    }
}
