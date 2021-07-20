import SwiftUI
import SceneKit

struct Editor: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("3D model")
                    Spacer()
                    Image(systemName: "move.3d")
                }
                .opacity(0.3)
                SceneView(
                    scene: model.data.scene,
                    pointOfView: model.data.camera,
                    options: [.allowsCameraControl]
                )
                .frame(height: 230)
                .padding(.horizontal, -16)
                .padding(.vertical, -6)
                .onChange(of: colorscheme) { value in
                    withAnimation {
                        model.data.colorscheme = value
                    }
                }
            }
            Section {
                HStack {
                    Text("Size")
                    Spacer()
                    Image(systemName: "selection.pin.in.out")
                }
                .opacity(0.3)
                HStack {
                    Text("Width")
                    Spacer()
                    Menu {
                        ForEach(Array(stride(from: 10, to: 201, by: 5)), id: \.self) { value in
                            Button(action: {
                                withAnimation {
                                    model.data.frames[model.data.selected].width = CGFloat(value)
                                }
                            }) {
                                Text("\(value) cm")
                            }
                        }
                    } label: {
                        Text("\(Int(model.data.frames[model.data.selected].width)) cm")
                    }
                }
                HStack {
                    Text("Height")
                    Spacer()
                    Menu {
                        ForEach(Array(stride(from: 10, to: 201, by: 5)), id: \.self) { value in
                            Button(action: {
                                withAnimation {
                                    model.data.frames[model.data.selected].height = CGFloat(value)
                                }
                            }) {
                                Text("\(value) cm")
                            }
                        }
                    } label: {
                        Text("\(Int(model.data.frames[model.data.selected].height)) cm")
                    }
                }
                HStack {
                    Text("Border")
                    Spacer()
                    Menu {
                        ForEach(Array(stride(from: 0.01, to: 0.21, by: 0.01)), id: \.self) { value in
                            Button(action: {
                                withAnimation {
                                    model.data.frames[model.data.selected].border = CGFloat(value)
                                }
                            }) {
                                Text("\(value) cm")
                            }
                        }
                    } label: {
                        Text("\(model.data.frames[model.data.selected].border) cm")
                    }
                }
            }
            Section {
                HStack {
                    Text("Filters")
                    Spacer()
                    Image(systemName: "camera.filters")
                }
                .opacity(0.3)
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
                    ForEach(model.filters, id: \.self) { filter in
                        Button(action: {
                            model.data.frames[model.data.selected].filter = filter
                        }) {
                            Image(uiImage: model.filterImage(filter: filter))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .if (model.data.frames[model.data.selected].filter == filter) { view in
                                    view.border(Color.accentColor, width: 4)
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
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
                        Button(action: {
                            model.data.frames[model.data.selected].material = material
                        }) {
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
                            .if (model.data.frames[model.data.selected].material == material) { view in
                                view.border(Color.accentColor, width: 4)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 10)
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
                if model.data.frames.count > 1 {
                    Button(action: {
                        withAnimation {
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
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    model.data.frames[model.data.selected].filter = "None"
                    model.data.frames[model.data.selected].material = "Oak"
                    model.data.frames[model.data.selected].width = 60
                    model.data.frames[model.data.selected].height = 90
                }) {
                    Text("Reset")
                }
                .disabled(
                    model.data.frames[model.data.selected].filter == "None" && model.data.frames[model.data.selected].material == "Oak" && model.data.frames[model.data.selected].width == 60 && model.data.frames[model.data.selected].height == 90
                )
            }
        }
        .onAppear {
            model.data.colorscheme = colorscheme
        }
    }
    
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Editor(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12")
    }
}
