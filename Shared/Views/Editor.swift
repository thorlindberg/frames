import SwiftUI

struct Editor: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: model.data.frames[index].transform)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
                .frame(height: 200)
            List {
                Section {
                    HStack {
                        Text("Filters")
                        Spacer()
                        Image(systemName: "camera.filters")
                    }
                    .opacity(0.3)
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
                        ForEach(model.filters, id: \.self) { filter in
                            Image(uiImage: model.filterImage(filter: filter))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    model.data.frames[model.data.selected].filter = filter
                                    model.transformImage(index: model.data.selected)
                                }
                                .if (model.data.frames[model.data.selected].filter == filter) { view in
                                    view.border(Color.accentColor, width: 4)
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
                Section {
                    HStack {
                        Text("Materials")
                        Spacer()
                        Image(systemName: "cube")
                    }
                    .opacity(0.3)
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
                        ForEach(model.materials, id: \.self) { material in
                            ZStack {
                                switch material {
                                    case "Oak": Image("material_oak")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    case "Steel": Image("material_steel")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    case "Marble": Image("material_marble")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    default: Image("Oak")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                            .onTapGesture {
                                model.data.frames[model.data.selected].material = material
                                model.transformImage(index: model.data.selected)
                            }
                            .if (model.data.frames[model.data.selected].material == material) { view in
                                view.border(Color.accentColor, width: 4)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                Section {
                    HStack {
                        Text("Size")
                        Spacer()
                        Image(systemName: "selection.pin.in.out")
                    }
                    .opacity(0.3)
                    Stepper(
                        "Width: \(Int(model.data.frames[model.data.selected].size.width))",
                        value: Binding(
                            get: { model.data.frames[model.data.selected].size.width },
                            set: {
                                model.data.frames[model.data.selected].size.width = $0
                                model.transformImage(index: model.data.selected)
                            }
                        ),
                        in: 10...200
                    )
                    Stepper(
                        "Height: \(Int(model.data.frames[model.data.selected].size.height))",
                        value: Binding(
                            get: { model.data.frames[model.data.selected].size.height },
                            set: {
                                model.data.frames[model.data.selected].size.height = $0
                                model.transformImage(index: model.data.selected)
                            }
                        ),
                        in: 10...200
                    )
                }
                Section {
                    Button(action: {
                        UIApplication.shared.windows.filter({$0.isKeyWindow})
                            .first?
                            .rootViewController?
                            .present(UIActivityViewController(activityItems: [model.data.frames[model.data.selected].transform], applicationActivities: nil), animated: true)
                    }) {
                        HStack {
                            Text("Share")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    Button(action: {
                        //
                    }) {
                        HStack {
                            Text("Reset")
                            Spacer()
                            Image(systemName: "arrow.uturn.backward")
                        }
                    }
                    Button(action: {
                        withAnimation {
                            model.data.isEditing.toggle()
                            model.removeImage(index: model.data.selected)
                        }
                    }) {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "delete.left")
                        }
                    }
                    .accentColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
    
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12")
    }
}
