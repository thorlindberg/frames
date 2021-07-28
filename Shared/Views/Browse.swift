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
