import SwiftUI

struct Window: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            Frame(model: model)
                .onAppear {
                    model.transformImage()
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: $model.data.isAction) {
            ActionSheet(title: Text(""), buttons: [
                .default(Text("Import from Photos")) { model.data.isImporting.toggle() },
                .default(Text("Scan with Camera")) {
                    UIApplication.shared.windows.filter({$0.isKeyWindow})
                        .first?.rootViewController?
                        .present(model.getDocumentCameraViewController(), animated: true, completion: nil)
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model)
        }
        .sheet(isPresented: $model.data.isAugmenting) {
            Augment(model: model)
                .modifier(DisableModalDismiss(disabled: true))
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
                    UserDefaults.standard.set(true, forKey: "hasLaunched")
                    model.data.firstLaunch = false
                }) {
                    Text("I'm ready to rock 🤟")
                }
            }
            .padding(.vertical, 100)
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
