import SwiftUI

struct Framer: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .opacity(colorScheme == .dark ? 0 : 0.05)
                Image(uiImage: model.data.images[model.data.selected])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(35)
                    .contextMenu {
                        Button(action: {
                            model.removeImage(item: model.data.images[model.data.selected])
                        }) {
                            Label("Delete", systemImage: "delete.left")
                        }
                        .disabled(model.data.images.count == 1)
                    }
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 10) {
                        ForEach((1...model.data.images.count), id: \.self) { select in
                            Circle()
                                .opacity(select == model.data.selected + 1 ? 0.3 : 0.15)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .frame(height: 35)
                }
            }
            .gesture(DragGesture().onChanged { value in
                if value.translation.width > 0 {
                    model.data.selected = model.data.selected - 1
                } else if model.data.selected != model.data.images.count - 1 {
                    model.data.selected = model.data.selected + 1
                }
                if model.data.selected < 0 {
                    model.data.selected = 0
                }
            })
            Divider()
            ZStack {
                Rectangle()
                    .opacity(colorScheme == .dark ? 0.05 : 0)
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
