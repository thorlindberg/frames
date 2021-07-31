import SwiftUI
import SceneKit

struct RoundedRectangle: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct SectionDivider: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(colorscheme == .dark ? .black : Color(UIColor.secondarySystemBackground))
            HStack {
                RoundedRectangle(corners: [.topRight, .bottomRight], radius: 100)
                    .foregroundColor(colorscheme == .dark ? Color(UIColor.systemGray6) : .white)
                    .frame(width: 20)
                Spacer()
                RoundedRectangle(corners: [.topLeft, .bottomLeft], radius: 100)
                    .foregroundColor(colorscheme == .dark ? Color(UIColor.systemGray6) : .white)
                    .frame(width: 20)
            }
        }
        .frame(width: 60)
        .padding(.vertical, -6)
    }
    
}

struct Editor: View {
    
    @ObservedObject var model: Model
    var index: Int
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        GeometryReader { geometry in
            List {
                Section(header: Text("framed \(model.data.frames[model.data.selected].date)").padding(.top, 20)) {
                    SceneView(scene: model.data.scene, options: [.allowsCameraControl])
                        .frame(height: geometry.size.height / 2.5)
                        .padding(.vertical, -6)
                        .padding(.horizontal, -10)
                }
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
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.red)
                        .disabled(model.data.frames.count == 1)
                        .alert(isPresented: $model.data.isWarned) {
                            Alert(
                                title: Text("Delete this frame?"),
                                message: Text("This action cannot be undone"),
                                primaryButton: .destructive(Text("Delete")) {
                                    withAnimation {
                                        model.data.isEditing.toggle()
                                        model.removeImage(index: model.data.selected)
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        SectionDivider()
                        Button(action: {
                            UIApplication.shared.windows.filter({$0.isKeyWindow})
                                .first?
                                .rootViewController?
                                .present(
                                    UIActivityViewController(
                                        activityItems: [model.data.frames[model.data.selected].framed],
                                        applicationActivities: nil
                                    ),
                                    animated: true
                                )
                        }) {
                            HStack {
                                Text("Share")
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.accentColor)
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
        }
        .navigationBarTitle("Customize")
        .onAppear {
            model.data.selected = index
        }
        .toolbar {
            /*
            ToolbarItem(placement: .principal) {
                Text(UIDevice.current.userInterfaceIdiom == .pad ? "Augmented Frames" : "Frames")
                    .bold()
                    .onTapGesture {
                        model.data.welcome.toggle()
                    }
            }
            */
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    model.data.isAugmenting.toggle()
                }) {
                    Text("AR")
                }
            }
        }
    }
    
}
