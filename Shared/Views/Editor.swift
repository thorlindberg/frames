import SwiftUI

struct Editor: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        if !model.data.frames.isEmpty {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack {
                            Spacer()
                            HStack(spacing: 0) {
                                ForEach(model.data.isEditing ? model.data.frames.indices.filter({$0 == model.data.selected}) : Array(model.data.frames.indices), id: \.self) { index in
                                    Image(uiImage: model.data.frames[index].transform)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(.horizontal, 28)
                                        .padding(.vertical, model.data.isEditing ? nil : 28)
                                        .frame(width: geometry.size.width)
                                        .onTapGesture {
                                            if !model.data.welcome {
                                                withAnimation {
                                                    model.data.selected = index
                                                    model.data.isEditing.toggle()
                                                }
                                            }
                                        }
                                        .onAppear {
                                            model.transformImage(index: index)
                                        }
                                        .transition(index < model.data.selected ? .move(edge: .leading).combined(with: .opacity) : .move(edge: .trailing).combined(with: .opacity))
                                }
                            }
                            Spacer()
                        }
                    }
                    .disabled(model.data.isEditing)
                    .onTapGesture {
                        if model.data.isEditing && !model.data.welcome {
                            withAnimation {
                                model.data.isEditing.toggle()
                            }
                        }
                    }
                }
                .frame(height: model.data.isEditing ? 200 : nil)
                VStack(spacing: 0) {
                    Divider()
                    /*
                    HStack {
                        Spacer()
                        Capsule()
                            .foregroundColor(colorscheme == .dark ? Color.white : Color.black)
                            .frame(width: 60, height: 8)
                            .padding(.vertical, 10)
                            .opacity(0.2)
                        Spacer()
                    }
                    .background(colorscheme == .dark ? Color.black : Color(red: 0, green: 0, blue: 0, opacity: 0.05))
                    Divider()
                    */
                    List {
                        if model.data.isEditing {
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
                }
                .frame(height: model.data.isEditing ? nil : 0)
                .transition(.move(edge: .bottom))
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
