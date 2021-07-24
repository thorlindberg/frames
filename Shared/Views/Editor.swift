import SwiftUI

struct Editor: View {
    
    @ObservedObject var model: Model
    @State var sizeExpanded: Bool = false
    @State var filtersExpanded: Bool = false
    @State var materialsExpanded: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                List {
                    Section {
                        ScrollStack(
                            items: model.data.frames.count, direction: .horizontal,
                            size: geometry.size.height - 300, spacing: 14, selection: $model.data.selected
                        ) {
                            ForEach(Array(model.data.frames.indices), id: \.self) { index in
                                Image(uiImage: model.data.frames[index].framed)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.height - 300)
                                    .opacity(model.data.selected == index ? 1 : 0.3)
                                    .padding(.vertical, 28)
                            }
                        }
                        .frame(height: geometry.size.height - 200)
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
                    Section {
                        HStack {
                            Text("Size")
                            Spacer()
                            Image(systemName: sizeExpanded ? "chevron.up" : "chevron.down")
                        }
                        .contentShape(Rectangle())
                        .opacity(0.3)
                        .onTapGesture {
                            withAnimation {
                                if !sizeExpanded {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        proxy.scrollTo("size", anchor: .top)
                                    }
                                }
                                sizeExpanded.toggle()
                            }
                        }
                        if sizeExpanded {
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
                    }
                    .id("size")
                    Section {
                        HStack {
                            Text("Filters")
                            Spacer()
                            Image(systemName: filtersExpanded ? "chevron.up" : "chevron.down")
                        }
                        .contentShape(Rectangle())
                        .opacity(0.3)
                        .onTapGesture {
                            withAnimation {
                                if !filtersExpanded {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        proxy.scrollTo("filters", anchor: .top)
                                    }
                                }
                                filtersExpanded.toggle()
                            }
                        }
                        if filtersExpanded {
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
                    }
                    .id("filters")
                    Section {
                        HStack {
                            Text("Materials")
                            Spacer()
                            Image(systemName: materialsExpanded ? "chevron.up" : "chevron.down")
                        }
                        .contentShape(Rectangle())
                        .opacity(0.3)
                        .onTapGesture {
                            withAnimation {
                                if !materialsExpanded {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        proxy.scrollTo("materials", anchor: .top)
                                    }
                                }
                                materialsExpanded.toggle()
                            }
                        }
                        if materialsExpanded {
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
                    .id("materials")
                    /*
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
                     }
                     */
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
