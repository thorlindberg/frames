import SwiftUI

struct Editor: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        if !model.data.frames.isEmpty {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack {
                            Spacer()
                            HStack(spacing: 0) {
                                ForEach(model.data.frames.indices, id: \.self) { index in
                                    Image(uiImage: model.data.frames[index].transform)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(.leading, 28)
                                        .padding(.vertical, model.data.isEditing ? nil : 28)
                                        .frame(width: geometry.size.width - 28)
                                        .onTapGesture {
                                            withAnimation {
                                                model.data.selected = index
                                                model.data.isEditing.toggle()
                                            }
                                        }
                                }
                            }
                            Spacer()
                        }
                    }
                    .disabled(model.data.isEditing)
                    .onTapGesture {
                        if model.data.isEditing {
                            withAnimation {
                                model.data.isEditing.toggle()
                            }
                        }
                    }
                }
                if model.data.isEditing {
                    VStack(spacing: 0) {
                        Divider()
                        List {
                            Section {
                                HStack {
                                    Text("Frame size")
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
                                            model.transformImage()
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
                                            model.transformImage()
                                        }
                                    ),
                                    in: 10...200
                                )
                                /*
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
                                */
                            }
                            Section {
                                HStack {
                                    Text("Frame material")
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
                                            model.transformImage()
                                        }
                                        .if (model.data.frames[model.data.selected].material == material) { view in
                                            view.border(Color.accentColor, width: 4)
                                        }
                                    }
                                }
                                .padding(.vertical, 10)
                                /*
                                Picker(
                                    selection: Binding(
                                        get: { model.data.frames[model.data.selected].material },
                                        set: {
                                            model.data.frames[model.data.selected].material = $0
                                            model.transformImage()
                                        }
                                    ),
                                    label: HStack {
                                        Text("Frame material")
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
                                */
                            }
                            Section {
                                HStack {
                                    Text("Photo filter")
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
                                                model.transformImage()
                                            }
                                            .if (model.data.frames[model.data.selected].filter == filter) { view in
                                                view.border(Color.accentColor, width: 4)
                                            }
                                    }
                                }
                                .padding(.vertical, 10)
                                /*
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
                                */
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
