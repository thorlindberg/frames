import SwiftUI

struct Editor: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: model.data.frames[model.data.selected].transform)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(28)
                .frame(height: model.data.isEditing ? 300 : nil)
                .onTapGesture {
                    withAnimation {
                        model.data.isEditing.toggle()
                    }
                }
            if model.data.isEditing {
                VStack(spacing: 0) {
                    Divider()
                    List {
                        Section {
                            Picker(
                                selection: Binding(
                                    get: { model.data.frames[model.data.selected].material },
                                    set: {
                                        model.data.frames[model.data.selected].material = $0
                                        model.transformImage()
                                    }
                                ),
                                label: HStack {
                                    Text("Frame materials")
                                    Spacer()
                                    Image(systemName: "cube")
                                }
                                .opacity(0.3)
                            ) {
                                ForEach(model.materials, id: \.self) { material in
                                    Text(material)
                                        .tag(material)
                                }
                            }
                            .pickerStyle(InlinePickerStyle())
                        }
                        Section {
                            Picker(
                                selection: Binding(
                                    get: { model.data.frames[model.data.selected].size },
                                    set: {
                                        model.data.frames[model.data.selected].size = $0
                                        withAnimation {
                                            model.transformImage()
                                        }
                                    }
                                ),
                                label: HStack {
                                    Text("Frame sizes")
                                    Spacer()
                                    Image(systemName: "selection.pin.in.out")
                                }
                                .opacity(0.3)
                            ) {
                                ForEach(model.sizes, id: \.self) { size in
                                    Text("\(Int(size.width))x\(Int(size.height)) cm")
                                        .tag(size)
                                }
                            }
                            .pickerStyle(InlinePickerStyle())
                        }
                        Section {
                            Picker(
                                selection: Binding(
                                    get: { model.data.frames[model.data.selected].filter },
                                    set: {
                                        model.data.frames[model.data.selected].filter = $0
                                        model.transformImage()
                                    }
                                ),
                                label: HStack {
                                    Text("Photo filters")
                                    Spacer()
                                    Image(systemName: "camera.filters")
                                }
                                .opacity(0.3)
                            ) {
                                ForEach(model.filters, id: \.self) { filter in
                                    Text(filter)
                                        .tag(filter)
                                }
                            }
                            .pickerStyle(InlinePickerStyle())
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            model.transformImage()
        }
    }
    
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
