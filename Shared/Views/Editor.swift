import SwiftUI
import SceneKit

struct Editor: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("3D model")
                        Spacer()
                        Image(systemName: "move.3d")
                    }
                    .opacity(0.3)
                    SceneView(
                        scene: model.scene,
                        pointOfView: model.camera,
                        options: [.allowsCameraControl]
                    )
                    .frame(height: 230)
                    .padding(.horizontal, -16)
                    .padding(.vertical, -16)
                    .onChange(of: colorscheme) { value in
                        withAnimation {
                            model.data.colorscheme = value
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
                    if model.data.frames.count > 1 {
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
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        model.data.isEditing.toggle()
                    }) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if model.data.frames[model.data.selected].filter != "None" || model.data.frames[model.data.selected].material != "Oak" || model.data.frames[model.data.selected].size != Data.Size(width: 60, height: 90) {
                        Text("Reset")
                            .foregroundColor(.orange)
                            .bold()
                            .onTapGesture {
                                model.data.frames[model.data.selected].filter = "None"
                                model.data.frames[model.data.selected].material = "Oak"
                                model.data.frames[model.data.selected].size = Data.Size(width: 60, height: 90)
                                withAnimation {
                                    model.transformImage(index: model.data.selected)
                                }
                            }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
