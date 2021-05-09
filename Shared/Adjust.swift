import SwiftUI

struct Adjust: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .opacity(colorScheme == .dark ? 0 : 0.05)
                if model.data.frames.isEmpty {
                    Image(systemName: "photo")
                        .opacity(0.15)
                        .font(.system(size: 150))
                } else {
                    Image(uiImage: model.data.frames[model.data.selected].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(30)
                        .contextMenu {
                            Button(action: {
                                UIApplication.shared.windows.filter({$0.isKeyWindow})
                                    .first?
                                    .rootViewController?
                                    .present(UIActivityViewController(activityItems: [model.data.frames[model.data.selected]], applicationActivities: nil), animated: true)
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            Button(action: {
                                model.removeImage(item: model.data.frames[model.data.selected].image)
                            }) {
                                Label("Delete", systemImage: "delete.left")
                            }
                        }
                    if model.data.frames.count != 1 {
                        VStack(spacing: 0) {
                            Spacer()
                            HStack(spacing: 10) {
                                ForEach((1...model.data.frames.count), id: \.self) { select in
                                    Circle()
                                        .opacity(select == model.data.selected + 1 ? 0.3 : 0.15)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .frame(height: 30)
                        }
                    }
                }
            }
            .gesture(DragGesture().onChanged { value in
                if value.translation.width > 0 {
                    model.data.selected = model.data.selected - 1
                } else if model.data.selected != model.data.frames.count - 1 {
                    model.data.selected = model.data.selected + 1
                }
                if model.data.selected < 0 {
                    model.data.selected = 0
                }
            })
        }
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
            ToolbarItem(placement: .bottomBar) {
                if !model.data.frames.isEmpty {
                    HStack {
                        Spacer()
                        Button(action: {
                            model.data.isAdjusting.toggle()
                        }) {
                            Text("\(model.data.frames[model.data.selected].width) x \(model.data.frames[model.data.selected].height) cm")
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
}
