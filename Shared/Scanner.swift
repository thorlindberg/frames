import SwiftUI

struct Scanner: View {
    
    @Binding var data: Data.Format
    
    var body: some View {
        VStack {
            Button(action: {
                data.isScanning.toggle()
            }) {
                Text("[SAVE SCAN]")
            }
        }
    }
    
}
