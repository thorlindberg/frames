import SwiftUI

struct Window: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            Frame(model: model)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("Frames")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Menu {
                            Button(action: {
                                model.data.isImporting.toggle()
                            }) {
                                Label("Import from Photos", systemImage: "photo")
                            }
                            Button(action: {
                                UIApplication.shared.windows.filter({$0.isKeyWindow})
                                    .first?.rootViewController?
                                    .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                            }) {
                                Label("Scan with Camera", systemImage: "viewfinder")
                            }
                        } label: {
                            Image(systemName: "camera")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        NavigationLink(
                            destination: Augment(model: model),
                            isActive: $model.data.isAugmenting,
                            label: {
                                Text("AR")
                            }
                        )
                        .isDetailLink(false)
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 20))
                            .onTapGesture {
                                model.data.welcome.toggle()
                            }
                        Spacer()
                        HStack(spacing: 30) {
                            Image(systemName: "camera.filters")
                                .font(.system(size: 20))
                                .foregroundColor(model.data.isFiltering ? .purple : nil)
                                .onTapGesture {
                                    model.data.fromLeft = true
                                    withAnimation {
                                        model.toggleAdjust()
                                        model.data.isFiltering = true
                                    }
                                }
                            Image(systemName: "cube")
                                .font(.system(size: 20))
                                .foregroundColor(model.data.isStyling ? .green : nil)
                                .onTapGesture {
                                    withAnimation {
                                        model.toggleAdjust()
                                        model.data.isStyling = true
                                    }
                                }
                            Image(systemName: "selection.pin.in.out")
                                .font(.system(size: 20))
                                .foregroundColor(model.data.isAdjusting ? .orange : nil)
                                .onTapGesture {
                                    model.data.fromLeft = false
                                    withAnimation {
                                        model.toggleAdjust()
                                        model.data.isAdjusting = true
                                    }
                                }
                        }
                        Spacer()
                        Image(systemName: "square.on.square") // does nothing right now
                            .font(.system(size: 20))
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // disables split view on iPad
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model)
        }
        .sheet(isPresented: $model.data.welcome) {
            Welcome(model: model)
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
