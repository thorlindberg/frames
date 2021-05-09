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
                                    model.data.isFiltering.toggle()
                                }
                            }) {
                                Image(systemName: "camera.filters")
                            }
                            Spacer()
                            Button(action: {
                                //
                            }) {
                                Image(systemName: "wand.and.stars.inverse")
                            }
                            Spacer()
                            Button(action: {
                                model.data.isAdjusting.toggle()
                            }) {
                                if model.data.frames[model.data.selected].width == 0 {
                                    Text("None")
                                } else {
                                    Text("\(Int(model.data.frames[model.data.selected].width)) x \(Int(model.data.frames[model.data.selected].height))")
                                }
                            }
                            Spacer()
                            Button(action: {
                                //
                            }) {
                                Image(systemName: "aspectratio")
                            }
                            Spacer()
                            Button(action: {
                                //
                            }) {
                                Image(systemName: "slider.horizontal.below.square.fill.and.square")
                            }
                        }
                    }
                }
        }
        .actionSheet(isPresented: $model.data.isAdjusting) {
            ActionSheet(title: Text("Aspect ratio"), buttons: [
                .default(Text("70 x 50 cm")) { withAnimation { model.data.frames[model.data.selected].width = 70 ; model.data.frames[model.data.selected].height = 50 } },
                .default(Text("50 x 50 cm")) { withAnimation { model.data.frames[model.data.selected].width = 50 ; model.data.frames[model.data.selected].height = 50 } },
                .default(Text("50 x 70 cm")) { withAnimation { model.data.frames[model.data.selected].width = 50 ; model.data.frames[model.data.selected].height = 70 } },
                .default(Text("400 x 50 cm")) { withAnimation { model.data.frames[model.data.selected].width = 400 ; model.data.frames[model.data.selected].height = 50 } },
                .default(Text("No frame")) { withAnimation { model.data.frames[model.data.selected].width = 0 ; model.data.frames[model.data.selected].height = 0 } },
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
                ARQuickLookView()
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
