import SwiftUI

struct Window: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            Frame(model: model)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Augmented Frames")
                .onAppear { model.transformImage() }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            model.data.isAdjusting = false
                            model.data.isAction.toggle()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            model.data.isAugmenting.toggle()
                        }) {
                            Text("AR")
                        }
                        .disabled(model.data.frames.isEmpty)
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        if !model.data.frames.isEmpty {
                            Button(action: {
                                model.data.frames[model.data.selected].filled.toggle()
                                if model.data.frames[model.data.selected].width != model.data.frames[model.data.selected].height && !model.data.frames[model.data.selected].filled {
                                    model.data.frames[model.data.selected].bordered = true
                                }
                                model.transformImage()
                            }) {
                                if model.data.frames[model.data.selected].filled {
                                    Image(systemName: "rectangle.compress.vertical")
                                } else {
                                    Image(systemName: "rectangle.expand.vertical")
                                }
                            }
                            Spacer()
                            Button(action: {
                                model.data.frames[model.data.selected].bordered.toggle()
                                if model.data.frames[model.data.selected].width != model.data.frames[model.data.selected].height && !model.data.frames[model.data.selected].bordered {
                                    model.data.frames[model.data.selected].filled = true
                                }
                                model.transformImage()
                            }) {
                                if model.data.frames[model.data.selected].bordered {
                                    Image(systemName: "square")
                                } else {
                                    Image(systemName: "square.dashed")
                                }
                            }
                            Spacer()
                            Button(action: {
                                model.data.isAdjusting = true
                                model.data.isAction.toggle()
                            }) {
                                Text("\(Int(model.data.frames[model.data.selected].width)) x \(Int(model.data.frames[model.data.selected].height))")
                            }
                            Spacer()
                            Button(action: {
                                model.data.frames[model.data.selected].rotation = model.data.frames[model.data.selected].rotation - 90
                                if model.data.frames[model.data.selected].rotation == -360 {
                                    model.data.frames[model.data.selected].rotation = 0
                                }
                                model.transformImage()
                            }) {
                                Image(systemName: "rotate.left")
                            }
                            .disabled(true)
                            Spacer()
                            Button(action: {
                                //
                                model.transformImage()
                            }) {
                                Image(systemName: "circle")
                            }
                            .disabled(true)
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: $model.data.isAction) {
            ActionSheet(title: Text(""), buttons: model.data.isAdjusting ? [
                .default(Text("13 x 18 cm")) { withAnimation { model.data.frames[model.data.selected].width = 13 ; model.data.frames[model.data.selected].height = 18 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("15 x 20 cm")) { withAnimation { model.data.frames[model.data.selected].width = 15 ; model.data.frames[model.data.selected].height = 20 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("21 x 30 cm")) { withAnimation { model.data.frames[model.data.selected].width = 21 ; model.data.frames[model.data.selected].height = 30 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("30 x 40 cm")) { withAnimation { model.data.frames[model.data.selected].width = 30 ; model.data.frames[model.data.selected].height = 40 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("30 x 45 cm")) { withAnimation { model.data.frames[model.data.selected].width = 30 ; model.data.frames[model.data.selected].height = 45 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("40 x 50 cm")) { withAnimation { model.data.frames[model.data.selected].width = 40 ; model.data.frames[model.data.selected].height = 50 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("45 x 60 cm")) { withAnimation { model.data.frames[model.data.selected].width = 45 ; model.data.frames[model.data.selected].height = 60 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("50 x 50 cm")) { withAnimation { model.data.frames[model.data.selected].width = 50 ; model.data.frames[model.data.selected].height = 50 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("50 x 70 cm")) { withAnimation { model.data.frames[model.data.selected].width = 50 ; model.data.frames[model.data.selected].height = 70 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("60 x 80 cm")) { withAnimation { model.data.frames[model.data.selected].width = 60 ; model.data.frames[model.data.selected].height = 80 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("60 x 90 cm")) { withAnimation { model.data.frames[model.data.selected].width = 60 ; model.data.frames[model.data.selected].height = 90 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .default(Text("70 x 100 cm")) { withAnimation { model.data.frames[model.data.selected].width = 70 ; model.data.frames[model.data.selected].height = 100 ; if !model.data.frames[model.data.selected].bordered { model.data.frames[model.data.selected].filled = true } ; model.transformImage() } },
                .cancel()
            ] : [
                .default(Text("Import from Photos")) { model.data.isImporting.toggle() },
                .default(Text("Scan with Camera")) {
                    UIApplication.shared.windows.filter({$0.isKeyWindow})
                    .first?
                    .rootViewController?
                    .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model)
        }
        .sheet(isPresented: $model.data.isAugmenting) {
            Augment(model: model)
                .modifier(DisableModalDismiss(disabled: true))
        }
        .sheet(isPresented: $model.data.firstLaunch) {
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
            .modifier(DisableModalDismiss(disabled: true))
        }
    }
    
}

struct Window_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
