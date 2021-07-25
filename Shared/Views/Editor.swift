import SwiftUI

struct Editor: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                List {
                    Section {
                        Button(action: {
                            withAnimation {
                                model.data.isBrowsing.toggle()
                            }
                        }) {
                            HStack {
                                Text("Browse")
                                Spacer()
                                Image(systemName: "photo.on.rectangle.angled")
                            }
                        }
                        if model.data.isBrowsing {
                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                                ForEach(model.data.frames.indices, id: \.self) { index in
                                    Button(action: {
                                        withAnimation {
                                            model.data.selected = index
                                            model.data.isBrowsing.toggle()
                                        }
                                    }) {
                                        Image(uiImage: model.data.frames[index].framed)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: geometry.size.height - 385)
                                            .padding(.vertical)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 14)
                        } else {
                            HStack {
                                Spacer()
                                Image(uiImage: model.data.frames[model.data.selected].framed)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: geometry.size.height - 385)
                                    .padding(.vertical)
                                Spacer()
                            }
                        }
                    }
                    Section {
                        HStack {
                            Text("Size")
                            Spacer()
                            Image(systemName: "selection.pin.in.out")
                        }
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
                    .disabled(model.data.isBrowsing)
                    .id("size")
                    Section {
                        HStack {
                            Text("Filters")
                            Spacer()
                            Image(systemName: "camera.filters")
                        }
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
                    .disabled(model.data.isBrowsing)
                    Section {
                        HStack {
                            Text("Materials")
                            Spacer()
                            Image(systemName: "cube")
                        }
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
                    .disabled(model.data.isBrowsing)
                    if model.data.frames.count > 1 {
                        Section {
                            Button(action: {
                                model.removeImage(index: model.data.selected)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // might have to increase delay to 0.1+
                                    withAnimation {
                                        proxy.scrollTo("size", anchor: .bottom)
                                    }
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
                        .disabled(model.data.isBrowsing)
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
