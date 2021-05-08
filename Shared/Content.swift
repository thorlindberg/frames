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
                .default(Text("10 x 70 cm")) { model.data.frameWidth = 10 ; model.data.frameHeight = 70 },
                .default(Text("20 x 70 cm")) { model.data.frameWidth = 20 ; model.data.frameHeight = 70 },
                .default(Text("30 x 70 cm")) { model.data.frameWidth = 30 ; model.data.frameHeight = 70 },
                .default(Text("40 x 70 cm")) { model.data.frameWidth = 40 ; model.data.frameHeight = 70 },
                .default(Text("50 x 70 cm")) { model.data.frameWidth = 50 ; model.data.frameHeight = 70 },
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
