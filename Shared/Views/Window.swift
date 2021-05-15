import SwiftUI

struct Window: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            Frame(model: model)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Frames")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            model.data.isAdjusting = false
                            model.data.isAction.toggle()
                        }) {
                            Image(systemName: "camera")
                        }
                    }
                    ToolbarItemGroup(placement: .confirmationAction) {
                        Button(action: {
                            model.data.isModeling.toggle()
                        }) {
                            Text("3D")
                        }
                        .disabled(model.data.frames.isEmpty)
                        Button(action: {
                            model.data.isAugmenting.toggle()
                        }) {
                            Text("AR")
                        }
                        .disabled(model.data.frames.isEmpty)
                        Button(action: {
                            model.data.isQuickLooking.toggle()
                        }) {
                            Image(systemName: "loupe")
                        }
                        .disabled(model.data.frames.isEmpty)
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
                                withAnimation {
                                    model.data.frames[model.data.selected].rotated = model.data.frames[model.data.selected].rotated - 90
                                }
                                if model.data.frames[model.data.selected].rotated == -360 {
                                    model.data.frames[model.data.selected].rotated = 0
                                }
                            }) {
                                Image(systemName: "rotate.left")
                            }
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    model.data.frames[model.data.selected].colored.toggle()
                                }
                            }) {
                                if model.data.frames[model.data.selected].colored {
                                    Image(systemName: "dial.max")
                                } else {
                                    Image(systemName: "dial.min")
                                }
                            }
                            /*
                            Menu {
                                Button(action: {
                                    withAnimation {
                                        model.data.frames[model.data.selected].colored.toggle()
                                    }
                                }) {
                                    if model.data.frames[model.data.selected].colored {
                                        Label("De-color", systemImage: "dial.min")
                                    } else {
                                        Label("Color", systemImage: "dial.max")
                                    }
                                }
                                Button(action: {
                                    withAnimation {
                                        model.data.frames[model.data.selected].brightened.toggle()
                                    }
                                }) {
                                    if model.data.frames[model.data.selected].brightened {
                                        Label("Darken", systemImage: "sun.min")
                                    } else {
                                        Label("Brighten", systemImage: "sun.max")
                                    }
                                }
                                Button(action: {
                                    withAnimation {
                                        model.data.frames[model.data.selected].inverted.toggle()
                                    }
                                }) {
                                    if model.data.frames[model.data.selected].inverted {
                                        Label("Revert", systemImage: "circle.lefthalf.fill")
                                    } else {
                                        Label("Invert", systemImage: "circle.righthalf.fill")
                                    }
                                }
                                Text("Filters")
                            } label: {
                                Image(systemName: "camera.filters")
                            }
                            */
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: $model.data.isAction) {
            ActionSheet(title: Text(""), buttons: model.data.isAdjusting ? [
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
        .sheet(isPresented: $model.data.isModeling) {
            Object(model: model)
                .modifier(DisableModalDismiss(disabled: true))
        }
        .sheet(isPresented: $model.data.isAugmenting) {
            Augment(model: model)
                .modifier(DisableModalDismiss(disabled: true))
        }
        .sheet(isPresented: $model.data.isQuickLooking) {
            QuickLook(model: model)
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
