import SwiftUI

struct Browse: View {
    
    @ObservedObject var model: Model
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                List {
                    ForEach(model.data.frames.indices, id: \.self) { index in
                        Section {
                            HStack {
                                Spacer()
                                Image(uiImage: model.data.frames[index].framed)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                                Spacer()
                            }
                            .background(
                                NavigationLink(destination: Editor(model: model)) { }
                                    .opacity(0)
                            )
                            .frame(maxHeight: geometry.size.height / 2)
                            .contextMenu {
                                Button(action: {
                                    UIApplication.shared.windows.filter({$0.isKeyWindow})
                                        .first?
                                        .rootViewController?
                                        .present(UIActivityViewController(activityItems: [model.data.frames[index].framed], applicationActivities: nil), animated: true)
                                }) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                Button(action: {
                                    model.removeImage(index: index)
                                }) {
                                    Label("Delete", systemImage: "delete.left")
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Augmented Frames")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Menu {
                        Button(action: {
                            model.data.isImporting.toggle()
                        }) {
                            Label("Choose Photo", systemImage: "photo")
                        }
                        Button(action: {
                            model.data.isCapturing.toggle()
                        }) {
                            Label("Capture Photo", systemImage: "camera")
                        }
                        Button(action: {
                            UIApplication.shared.windows.filter({$0.isKeyWindow})
                                .first?.rootViewController?
                                .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                        }) {
                            Label("Scan Photo", systemImage: "viewfinder")
                        }
                    } label: {
                        Image(systemName: "camera.fill")
                    }
                }
                /*
                ToolbarItem(placement: .principal) {
                    Text(UIDevice.current.userInterfaceIdiom == .pad ? "Augmented Frames" : "Frames")
                        .bold()
                        .onTapGesture {
                            model.data.welcome.toggle()
                        }
                }
                */
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            model.data.colorscheme = colorscheme
        }
        .onChange(of: colorscheme) { value in
            withAnimation {
                model.data.colorscheme = value
            }
        }
    }
    
}

struct Browse_Previews: PreviewProvider {
    static var previews: some View {
        Window(model: Model())
            .previewDevice("iPhone 12 mini")
    }
}

/*
GeometryReader { geometry in
    if model.data.isEditing {
        List {
            Section {
                HStack(spacing: 0) {
                    Button(action: {
                        model.data.isWarned.toggle()
                    }) {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "delete.left")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.red)
                    .alert(isPresented: $model.data.isWarned) {
                        Alert(
                            title: Text("Delete this frame?"),
                            message: Text("This action cannot be undone"),
                            primaryButton: .destructive(Text("Delete")) {
                                withAnimation {
                                    model.removeImage(index: model.data.selected)
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    ZStack {
                        Rectangle()
                            .foregroundColor(colorscheme == .dark ? .black : Color(UIColor.secondarySystemBackground))
                        HStack {
                            RoundedCornersShape(corners: [.topRight, .bottomRight], radius: 100)
                                .foregroundColor(colorscheme == .dark ? Color(UIColor.systemGray6) : .white)
                                .frame(width: 20)
                            Spacer()
                            RoundedCornersShape(corners: [.topLeft, .bottomLeft], radius: 100)
                                .foregroundColor(colorscheme == .dark ? Color(UIColor.systemGray6) : .white)
                                .frame(width: 20)
                        }
                    }
                    .frame(width: 54)
                    .padding(.vertical, -6)
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
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.accentColor)
                }
            }
            Section {
                HStack {
                    Spacer()
                    Image(uiImage: model.data.frames[model.data.selected].framed)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    Spacer()
                }
            }
            .frame(height: geometry.size.height / 3)
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
        .listStyle(InsetGroupedListStyle())
        .transition(.move(edge: .trailing))
    } else {
        List {
            ForEach(model.data.frames.indices, id: \.self) { index in
                Section {
                    Button(action: {
                        withAnimation {
                            model.data.selected = index
                            model.data.isEditing.toggle()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Image(uiImage: model.data.frames[index].framed)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
                            Spacer()
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            UIApplication.shared.windows.filter({$0.isKeyWindow})
                                .first?
                                .rootViewController?
                                .present(UIActivityViewController(activityItems: [model.data.frames[index].framed], applicationActivities: nil), animated: true)
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button(action: {
                            model.removeImage(index: index)
                        }) {
                            Label("Delete", systemImage: "delete.left")
                        }
                    }
                }
                .frame(height: geometry.size.height / 1.5)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .transition(.move(edge: .leading))
    }
}
*/
