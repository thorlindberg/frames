import SwiftUI

struct Content: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            Adjust(model: model)
        }
        .actionSheet(isPresented: $model.data.isAdjusting) {
            ActionSheet(title: Text("Aspect ratio"), buttons: [
                .default(Text("13 x 18 cm")) { model.data.frames[model.data.selected].width = 13 ; model.data.frames[model.data.selected].height = 18 },
                .default(Text("15 x 20 cm")) { model.data.frames[model.data.selected].width = 15 ; model.data.frames[model.data.selected].height = 20 },
                .default(Text("21 x 30 cm")) { model.data.frames[model.data.selected].width = 21 ; model.data.frames[model.data.selected].height = 30 },
                .default(Text("30 x 40 cm")) { model.data.frames[model.data.selected].width = 30 ; model.data.frames[model.data.selected].height = 40 },
                .default(Text("30 x 45 cm")) { model.data.frames[model.data.selected].width = 30 ; model.data.frames[model.data.selected].height = 45 },
                .default(Text("40 x 50 cm")) { model.data.frames[model.data.selected].width = 40 ; model.data.frames[model.data.selected].height = 50 },
                .default(Text("45 x 60 cm")) { model.data.frames[model.data.selected].width = 45 ; model.data.frames[model.data.selected].height = 60 },
                .default(Text("50 x 70 cm")) { model.data.frames[model.data.selected].width = 50 ; model.data.frames[model.data.selected].height = 70 },
                .default(Text("60 x 80 cm")) { model.data.frames[model.data.selected].width = 60 ; model.data.frames[model.data.selected].height = 80 },
                .default(Text("60 x 90 cm")) { model.data.frames[model.data.selected].width = 60 ; model.data.frames[model.data.selected].height = 90 },
                .default(Text("70 x 100 cm")) { model.data.frames[model.data.selected].width = 70 ; model.data.frames[model.data.selected].height = 100 },
                .cancel()
            ])
        }
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model)
        }
        .sheet(isPresented: $model.data.firstLaunch, onDismiss: { UserDefaults.standard.set(true, forKey: "hasLaunched") } ) {
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
