import SwiftUI

struct Content: View {
    
    @State var data: Data.Format = Data().data
    
    var body: some View {
        if data.isScanning {
            Scanner(data: $data, viewModel: ContentViewModel())
        } else {
            TabView(selection: $data.orientation) {
                Framer(data: $data).tabItem { Label("Vertical", systemImage: "rectangle.portrait") }
                    .tag("vertical")
                Framer(data: $data).tabItem { Label("Horizontal", systemImage: "rectangle") }
                    .tag("horizontal")
                Framer(data: $data).tabItem { Label("Quadrant", systemImage: "square") }
                    .tag("quadrant")
            }
        }
    }
    
}
