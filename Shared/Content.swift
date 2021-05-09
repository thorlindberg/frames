import SwiftUI

struct Content: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            Adjust(model: model)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Frames")
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Menu("Image") {
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
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if model.data.images.count != 1 {
                            Menu("AR") {
                                Button(action: {
                                    model.data.isAugmenting.toggle()
                                }) {
                                    Label("View photo collage", systemImage: "square.grid.3x2")
                                }
                                Button(action: {
                                    model.data.isAugmenting.toggle()
                                }) {
                                    Label("View single photo", systemImage: "square")
                                }
                            }
                        } else {
                            Button(action: {
                                model.data.isAugmenting.toggle()
                            }) {
                                Text("AR")
                            }
                        }
                    }
            }
        }
        .actionSheet(isPresented: $model.data.isAdjusting) {
            ActionSheet(title: Text("Aspect ratio"), buttons: [
                .default(Text("13 x 18 cm")) { model.data.frameWidth = 13 ; model.data.frameHeight = 18 },
                .default(Text("15 x 20 cm")) { model.data.frameWidth = 15 ; model.data.frameHeight = 20 },
                .default(Text("21 x 30 cm")) { model.data.frameWidth = 21 ; model.data.frameHeight = 30 },
                .default(Text("30 x 40 cm")) { model.data.frameWidth = 30 ; model.data.frameHeight = 40 },
                .default(Text("30 x 45 cm")) { model.data.frameWidth = 30 ; model.data.frameHeight = 45 },
                .default(Text("40 x 50 cm")) { model.data.frameWidth = 40 ; model.data.frameHeight = 50 },
                .default(Text("45 x 60 cm")) { model.data.frameWidth = 45 ; model.data.frameHeight = 60 },
                .default(Text("50 x 70 cm")) { model.data.frameWidth = 50 ; model.data.frameHeight = 70 },
                .default(Text("60 x 80 cm")) { model.data.frameWidth = 60 ; model.data.frameHeight = 90 },
                .default(Text("60 x 90 cm")) { model.data.frameWidth = 60 ; model.data.frameHeight = 90 },
                .default(Text("70 x 100 cm")) { model.data.frameWidth = 70 ; model.data.frameHeight = 100 },
                .cancel()
            ])
        }
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model)
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
                    model.data.firstLaunch.toggle()
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
