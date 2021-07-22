import SwiftUI
import SceneKit

struct Editor: View {
    
    @ObservedObject var model: Model
    @Environment(\.colorScheme) var colorscheme
    @State var color: Color = .red
    
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
                    scene: model.data.frames[model.data.selected].model,
                    // pointOfView: model.data.camera,
                    options: [.allowsCameraControl]
                )
                .frame(height: 230)
                .padding(.horizontal, -16)
                .padding(.vertical, -6)
                .onChange(of: colorscheme) { value in
                    withAnimation {
                        model.data.frames[model.data.selected].colorscheme = value
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
                                Text("\(value, specifier: "%.2f") cm")
                            }
                        }
                    } label: {
                        Text("\(model.data.frames[model.data.selected].border, specifier: "%.2f") cm")
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
                    ForEach(Array(model.data.frames[model.data.selected].image.keys.sorted(by: >)), id: \.self) { key in
                        Button(action: {
                            model.data.frames[model.data.selected].filter = key
                        }) {
                            Image(uiImage: model.data.frames[model.data.selected].image[key]!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .border(
                                    Color.accentColor,
                                    width: model.data.frames[model.data.selected].filter == key ? 4 : 0
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 14)
            }
            Section {
                HStack {
                    Text("Materials")
                    Spacer()
                    Image(systemName: "cube")
                }
                .opacity(0.3)
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
                    ForEach([UIImage(named: "material_oak"), UIImage(named: "material_steel"), UIImage(named: "material_marble")], id: \.self) { material in
                        Button(action: {
                            model.data.frames[model.data.selected].material = material!
                        }) {
                            Image(uiImage: material!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            .if (model.data.frames[model.data.selected].material == material) { view in
                                view.border(Color.accentColor, width: 4)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 14)
            }
            Section {
                Button(action: {
                    UIApplication.shared.windows.filter({$0.isKeyWindow})
                        .first?
                        .rootViewController?
                        .present(UIActivityViewController(activityItems: [model.data.frames[model.data.selected].framed], applicationActivities: nil), animated: true)
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
                    withAnimation {
                        model.data.frames[model.data.selected].filter = ""
                        model.data.frames[model.data.selected].material = UIImage(named: "material_oak")!
                        model.data.frames[model.data.selected].width = 50
                        model.data.frames[model.data.selected].height = 70
                        model.data.frames[model.data.selected].border = 0.05
                    }
                }) {
                    Text("Reset")
                }
                .disabled(
                     model.data.frames[model.data.selected].filter == "" && model.data.frames[model.data.selected].material == UIImage(named: "material_oak") && model.data.frames[model.data.selected].width == 50 && model.data.frames[model.data.selected].height == 70 && model.data.frames[model.data.selected].border == 0.05
                 )
            }
        }
        .onAppear {
            model.data.frames[model.data.selected].colorscheme = colorscheme
        }
    }
    
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Editor(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12")
    }
}
