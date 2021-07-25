import SwiftUI
import SceneKit

struct Editor: View {
    
    @ObservedObject var model: Model
    @Environment(\.colorScheme) var colorscheme
    @State var frame: Model.Frame?
    
    var body: some View {
        NavigationView {
            List {
                if let frame = frame {
                    Section {
                        HStack {
                            Text("3D model")
                            Spacer()
                            Image(systemName: "move.3d")
                        }
                        .opacity(0.3)
                        SceneView(
                            scene: model.data.scene,
                            options: [.allowsCameraControl]
                        )
                        .frame(height: 250)
                        .padding(.horizontal, -16)
                        .padding(.vertical, -6)
                        .onChange(of: colorscheme) { value in
                            withAnimation {
                                model.data.colorscheme = value
                            }
                        }
                    }
                } else {
                    Section {
                        Button(action: {
                            model.data.isEditing.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                model.data.isImporting.toggle()
                            }
                        }) {
                            HStack {
                                Text("Choose photo")
                                Spacer()
                                Image(systemName: "photo")
                            }
                        }
                        Button(action: {
                            model.data.isEditing.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                model.data.isCapturing.toggle()
                            }
                        }) {
                            HStack {
                                Text("Capture photo")
                                Spacer()
                                Image(systemName: "camera")
                            }
                        }
                        Button(action: {
                            model.data.isEditing.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                UIApplication.shared.windows.filter({$0.isKeyWindow})
                                    .first?.rootViewController?
                                    .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                            }
                        }) {
                            HStack {
                                Text("Scan photo")
                                Spacer()
                                Image(systemName: "viewfinder")
                            }
                        }
                    }
                }
                if let frame = frame {
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
                            ForEach(["", "noir", "mono", "invert"], id: \.self) { filter in
                                Button(action: {
                                    model.data.frames[model.data.selected].filter = filter
                                }) {
                                    Image(uiImage: filterImage(image: model.data.frames[model.data.selected].image, filter: filter))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .border(
                                            Color.accentColor,
                                            width: model.data.frames[model.data.selected].filter == filter ? 4 : 0
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
                                        .border(Color.accentColor, width: model.data.frames[model.data.selected].material == material ? 4 : 0)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 14)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Frame")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if model.data.isCreating {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .onTapGesture {
                                model.data.isCreating.toggle()
                                model.data.isEditing.toggle()
                            }
                    } else {
                        Button(action: {
                            model.data.isEditing.toggle()
                        }) {
                            Text("Close")
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if model.data.isCreating {
                        Button(action: {
                            model.data.isCreating.toggle()
                            model.data.isEditing.toggle()
                        }) {
                            Text("Create")
                        }
                    } else if model.data.frames.count > 1 {
                        Text("Reset")
                            .foregroundColor(.orange)
                            .onTapGesture {
                                // reset customization
                            }
                    }
                }
            }
        }
    }
    
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
