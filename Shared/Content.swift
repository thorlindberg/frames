import SwiftUI

struct Content: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            Frame(model: model)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Frames")
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Menu {
                            Button(action: {
                                model.data.isImporting.toggle()
                            }) {
                                Label("Import from Photos", systemImage: "photo")
                            }
                            Button(action: {
                                UIApplication.shared.windows.filter({$0.isKeyWindow})
                                    .first?
                                    .rootViewController?
                                    .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                            }) {
                                Label("Scan with Camera", systemImage: "viewfinder")
                            }
                        } label: {
                            Image(systemName: "camera")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            model.data.isAugmenting.toggle()
                        }) {
                            Text("AR")
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        if !model.data.frames.isEmpty {
                            Button(action: {
                                withAnimation {
                                    model.data.frames[model.data.selected].filled.toggle()
                                    if model.data.frames[model.data.selected].width != model.data.frames[model.data.selected].height && !model.data.frames[model.data.selected].filled {
                                        model.data.frames[model.data.selected].bordered = true
                                    }
                                }
                            }) {
                                if model.data.frames[model.data.selected].filled {
                                    Image(systemName: "rectangle.compress.vertical")
                                } else {
                                    Image(systemName: "rectangle.expand.vertical")
                                }
                            }
                            .disabled(model.data.frames[model.data.selected].width == model.data.frames[model.data.selected].height)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    model.data.frames[model.data.selected].bordered.toggle()
                                    if model.data.frames[model.data.selected].width != model.data.frames[model.data.selected].height && !model.data.frames[model.data.selected].bordered {
                                        model.data.frames[model.data.selected].filled = true
                                    }
                                }
                            }) {
                                if model.data.frames[model.data.selected].bordered {
                                    Image(systemName: "square.on.square.dashed")
                                } else {
                                    Image(systemName: "square.dashed")
                                }
                            }
                            Spacer()
                            Button(action: {
                                model.data.isAdjusting.toggle()
                            }) {
                                Text("\(Int(model.data.frames[model.data.selected].width)) x \(Int(model.data.frames[model.data.selected].height))")
                            }
                            Spacer()
                            Menu {
                                Button(action: {
                                    model.data.frames[model.data.selected].colored.toggle()
                                }) {
                                    if model.data.frames[model.data.selected].colored {
                                        Label("De-color", systemImage: "circle.lefthalf.fill")
                                    } else {
                                        Label("Color", systemImage: "circle.righthalf.fill")
                                    }
                                }
                                Text("Filters")
                            } label: {
                                Image(systemName: "camera.filters")
                            }
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    model.data.frames[model.data.selected].rotated = model.data.frames[model.data.selected].rotated - 90
                                }
                                if model.data.frames[model.data.selected].rotated == -360 {
                                    model.data.frames[model.data.selected].rotated = 0
                                }
                            }) {
                                Image(systemName: "rotate.left")
                            }
                        }
                    }
                }
        }
        .actionSheet(isPresented: $model.data.isAdjusting) {
            ActionSheet(title: Text("Aspect ratio"), buttons: [
                .default(Text("13 x 18 cm")) { withAnimation { model.data.frames[model.data.selected].width = 13 ; model.data.frames[model.data.selected].height = 18 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("15 x 20 cm")) { withAnimation { model.data.frames[model.data.selected].width = 15 ; model.data.frames[model.data.selected].height = 20 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("21 x 30 cm")) { withAnimation { model.data.frames[model.data.selected].width = 21 ; model.data.frames[model.data.selected].height = 30 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("30 x 40 cm")) { withAnimation { model.data.frames[model.data.selected].width = 30 ; model.data.frames[model.data.selected].height = 40 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("30 x 45 cm")) { withAnimation { model.data.frames[model.data.selected].width = 30 ; model.data.frames[model.data.selected].height = 45 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("40 x 50 cm")) { withAnimation { model.data.frames[model.data.selected].width = 40 ; model.data.frames[model.data.selected].height = 50 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("45 x 60 cm")) { withAnimation { model.data.frames[model.data.selected].width = 45 ; model.data.frames[model.data.selected].height = 60 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("50 x 50 cm")) { withAnimation { model.data.frames[model.data.selected].width = 50 ; model.data.frames[model.data.selected].height = 50 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("50 x 70 cm")) { withAnimation { model.data.frames[model.data.selected].width = 50 ; model.data.frames[model.data.selected].height = 70 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("60 x 80 cm")) { withAnimation { model.data.frames[model.data.selected].width = 60 ; model.data.frames[model.data.selected].height = 80 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("60 x 90 cm")) { withAnimation { model.data.frames[model.data.selected].width = 60 ; model.data.frames[model.data.selected].height = 90 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .default(Text("70 x 100 cm")) { withAnimation { model.data.frames[model.data.selected].width = 70 ; model.data.frames[model.data.selected].height = 100 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } } },
                .cancel()
            ])
        }
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model)
        }
        .sheet(isPresented: $model.data.firstLaunch, onDismiss: { UserDefaults.standard.set(true, forKey: "hasLaunched") } ) {
            VStack(spacing: 25) {
                Text("Welcome!")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                Spacer()
                Text("1. Scan/select image for framing")
                Divider().padding(.horizontal, 60)
                Text("2. Choose real-world frame size")
                Divider().padding(.horizontal, 60)
                Text("2. Preview framed image in AR")
                Spacer()
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "hasLaunched")
                    model.data.firstLaunch = false
                }) {
                    Text("I'm ready to rock 🤟")
                }
            }
            .padding(.vertical, 100)
        }
        .sheet(isPresented: $model.data.isAugmenting) {
            VStack {
                HStack {
                    Button("Close") {
                        model.data.isAugmenting.toggle()
                    }
                    Spacer()
                }
                .padding()
                ARQuickLookView(model: model)
            }
        }
    }
    
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             Content(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
