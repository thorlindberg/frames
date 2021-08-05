import SwiftUI

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct Window: View {
    
    @ObservedObject var model: Model
    @State var isLoaded: Bool = false
    @State var isBlurred: Bool = true

    var body: some View {
        ZStack {
            if model.data.isAugmenting {
                ARViewContainer(model: model)
                    .ignoresSafeArea()
            }
            if isBlurred {
                CameraView()
                    .ignoresSafeArea()
                Blur(style: .dark)
                    .ignoresSafeArea()
            }
            VStack {
                Spacer()
                if !model.data.isAugmenting {
                    Image(uiImage: model.data.frames[model.data.selected].framed)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(50)
                    Spacer()
                }
                HStack {
                    Spacer()
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
                        ZStack {
                            Blur(style: .dark)
                                .mask(Circle())
                            Image(systemName: "camera.fill")
                        }
                        .frame(width: 50, height: 50)
                    }
                    Spacer()
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                isBlurred.toggle()
                            }
                        }
                        withAnimation {
                            model.data.isAugmenting.toggle()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                            Image(systemName: "arrow.up")
                                .font(.system(size: 30))
                                .rotation3DEffect(
                                    .degrees(model.data.isAugmenting ? 180 : 0),
                                    axis: (x: 1.0, y: 0.0, z: 0.0)
                                )
                        }
                        .frame(width: 70, height: 70)
                    }
                    // .disabled(!isLoaded)
                    Spacer()
                    Button(action: {
                        //
                    }) {
                        ZStack {
                            Blur(style: .dark)
                                .mask(Circle())
                            Image(systemName: "crop")
                                .font(.system(size: 20))
                        }
                        .accentColor(.orange)
                        .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model, type: "import")
        }
        .sheet(isPresented: $model.data.isCapturing) {
            ImagePicker(model: model, type: "capture")
        }
    }
    
}

struct Window_Previews: PreviewProvider {
    static var previews: some View {
        Window(model: Model())
    }
}
