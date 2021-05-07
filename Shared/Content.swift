import SwiftUI

struct Content: View {
    
    @State var data: Data.Format = Data().data
    
    var body: some View {
        if data.isResizing {
            TabView(selection: $data.orientation) {
                Framer(data: $data, viewModel: ContentViewModel()).tabItem { Label("Vertical", systemImage: "rectangle.portrait") }
                    .tag("vertical")
                Framer(data: $data, viewModel: ContentViewModel()).tabItem { Label("Horizontal", systemImage: "rectangle") }
                    .tag("horizontal")
                Framer(data: $data, viewModel: ContentViewModel()).tabItem { Label("Quadrant", systemImage: "square") }
                    .tag("quadrant")
            }
        } else {
            Framer(data: $data, viewModel: ContentViewModel())
        }
    }
    
}
