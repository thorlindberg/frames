import SwiftUI

struct Browse: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    List {
                        ForEach(model.data.frames.indices, id: \.self) { index in
                            Section { // (header: Text("framed \(model.data.frames[index].date)").padding(.top, index == 0 ? 20 : 0))
                                HStack {
                                    Spacer()
                                    Image(uiImage: model.data.frames[index].framed)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    Spacer()
                                }
                                .padding(.horizontal, -18)
                                .padding()
                                .background(
                                    NavigationLink(destination: Editor(model: model, index: index)) { }
                                        .opacity(0)
                                )
                                .id(index)
                                .contextMenu {
                                    Button(action: {
                                        UIApplication.shared.windows.filter({$0.isKeyWindow})
                                            .first?
                                            .rootViewController?
                                            .present(
                                                UIActivityViewController(
                                                    activityItems: [model.data.frames[index].framed],
                                                    applicationActivities: nil
                                                ),
                                                animated: true
                                            )
                                    }) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    if model.data.frames.count != 1 {
                                        Button(action: {
                                            model.removeImage(index: index)
                                        }) {
                                            Label("Delete", systemImage: "delete.left")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .onChange(of: model.data.frames[0]) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                proxy.scrollTo(0, anchor: .bottom)
                            }
                        }
                    }
                }
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
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        model.data.isAugmenting.toggle()
                    }) {
                        Text("AR")
                    }
                    .disabled(true)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}

struct Browse_Previews: PreviewProvider {
    static var previews: some View {
        Window(model: Model())
            .previewDevice("iPhone 12 Pro Max")
        Window(model: Model())
            .previewDevice("iPhone 12")
        Window(model: Model())
            .previewDevice("iPhone 12 mini")
        Window(model: Model())
            .previewDevice("iPhone 8")
    }
}
