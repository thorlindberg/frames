import SwiftUI

struct Window: View {
    
    @ObservedObject var model: Model
    @Environment(\.colorScheme) var colorscheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .foregroundColor(colorscheme == .dark ? Color(UIColor.systemGray6) : .white)
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(colorscheme == .dark ? Color(UIColor.systemGray6) : .white)
                        HStack {
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
                            Spacer()
                            Button(action: {
                                model.data.isAugmenting.toggle()
                            }) {
                                Text("AR")
                                    .bold()
                            }
                        }
                        .padding(.horizontal)
                        Text("Augmented Frames")
                            .bold()
                    }
                    .frame(height: 50)
                    ZStack {
                        Rectangle()
                            .foregroundColor(.black)
                        RoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 10)
                            .foregroundColor(colorscheme == .dark ? Color(UIColor.systemGray6) : .white)
                        Image(uiImage: model.data.frames[0].framed)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(28)
                            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
                            .onTapGesture {
                                model.data.isEditing.toggle()
                            }
                    }
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(height: 5)
                    ZStack {
                        Rectangle()
                            .foregroundColor(.black)
                        RoundedRectangle(corners: [.topLeft, .topRight], radius: 10)
                            .foregroundColor(colorscheme == .dark ? Color(UIColor.systemGray6) : .white)
                        VStack {
                            Capsule()
                                .foregroundColor(Color(UIColor.systemGray4))
                                .frame(width: 50, height: 8)
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(height: 50)
                    .onTapGesture {
                        model.data.isEditing.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $model.data.welcome) {
            Welcome(model: model)
                .modifier(DisableModalDismiss(disabled: !UserDefaults.standard.bool(forKey: "beta83") ? true : false))
        }
        .sheet(isPresented: $model.data.isEditing) {
            Editor(model: model, index: 0)
        }
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model, type: "import")
        }
        .sheet(isPresented: $model.data.isCapturing) {
            ImagePicker(model: model, type: "capture")
        }
        .fullScreenCover(isPresented: $model.data.isAugmenting) {
            Augment(model: model)
        }
        .onAppear {
            model.data.colorscheme = colorscheme
        }
        .onChange(of: colorscheme) { value in
            withAnimation {
                model.data.colorscheme = value
            }
        }
        /*
        Browse(model: model)
            .sheet(isPresented: $model.data.welcome) {
                Welcome(model: model)
                    .modifier(DisableModalDismiss(disabled: !UserDefaults.standard.bool(forKey: "beta83") ? true : false))
            }
            .sheet(isPresented: $model.data.isImporting) {
                ImagePicker(model: model, type: "import")
            }
            .sheet(isPresented: $model.data.isCapturing) {
                ImagePicker(model: model, type: "capture")
            }
            .fullScreenCover(isPresented: $model.data.isAugmenting) {
                Augment(model: model)
            }
            .onAppear {
                model.data.colorscheme = colorscheme
            }
            .onChange(of: colorscheme) { value in
                withAnimation {
                    model.data.colorscheme = value
                }
            }
        */
    }
    
}

// source: https://stackoverflow.com/a/60939207/15072454

extension UIApplication {
    func visibleViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return nil }
        guard let rootViewController = window.rootViewController else { return nil }
        return UIApplication.getVisibleViewControllerFrom(vc: rootViewController)
    }
    private static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return UIApplication.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return UIApplication.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIApplication.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

struct DisableModalDismiss: ViewModifier {
    let disabled: Bool
    func body(content: Content) -> some View {
        disableModalDismiss()
        return AnyView(content)
    }
    func disableModalDismiss() {
        guard let visibleController = UIApplication.shared.visibleViewController() else { return }
        visibleController.isModalInPresentation = disabled
    }
}

struct Window_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
