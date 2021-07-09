import SwiftUI

struct Window: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    if model.data.isEditing {
                        Frame(model: model)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            ForEach(model.data.frames, id: \.self) { frame in
                                Frame(model: model)
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("Frames")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Text(model.data.isEditing ? "Cancel" : "Edit")
                            .foregroundColor(model.data.isEditing ? .red : .blue)
                            .onTapGesture {
                                withAnimation {
                                    model.data.isEditing.toggle()
                                }
                            }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Text(model.data.isEditing ? "Save" : "AR")
                            .foregroundColor(.blue)
                            .bold()
                            .onTapGesture {
                                withAnimation {
                                    if model.data.isEditing {
                                        model.data.isEditing.toggle()
                                    } else {
                                        model.data.isAugmenting.toggle()
                                    }
                                }
                            }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        HStack(spacing: 30) {
                            if model.data.isEditing {
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
                            } else {
                                Button(action: {
                                    model.data.isImporting.toggle()
                                }) {
                                    Text("Import")
                                }
                                Button(action: {
                                    UIApplication.shared.windows.filter({$0.isKeyWindow})
                                        .first?.rootViewController?
                                        .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                                }) {
                                    Text("Scan")
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
            if model.data.isAugmenting {
                NavigationView {
                    Augment(model: model)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(action: {
                                    withAnimation {
                                        model.data.isAugmenting.toggle()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                    }
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button(action: {
                                    model.data.isFlashlight.toggle()
                                    toggleTorch(on: model.data.isFlashlight)
                                }) {
                                    HStack {
                                        Text("Flash")
                                            .if (model.data.isFlashlight) { view in
                                                view.bold()
                                            }
                                        Image(systemName: model.data.isFlashlight ? "bolt.fill" : "bolt.slash")
                                    }
                                }
                            }
                        }
                }
                .transition(.move(edge: .trailing))
            }
        }
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
