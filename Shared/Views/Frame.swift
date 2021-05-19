import SwiftUI
import SceneKit

struct Frame: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            if model.data.frames.isEmpty {
                HStack {
                    Spacer()
                    Image(systemName: "photo")
                        .opacity(0.15)
                        .font(.system(size: 150))
                    Spacer()
                }
                Spacer()
            } else {
                SceneView(scene: model.scene, options: [.allowsCameraControl])
                Divider()
                if model.data.isBordering {
                    Slider(
                        value: Binding(
                            get: { model.data.frames[model.data.selected].border },
                            set: { model.data.frames[model.data.selected].border = $0 ; model.transformImage() }
                        ),
                        in: 0...1, step: 0.05
                    )
                    .padding()
                }
                if model.data.isStyling {
                    // frame materials
                }
                if model.data.isAdjusting {
                    // frame sizes
                }
                ZStack {
                    HStack {
                        Button(action: {
                            model.removeImage()
                        }) {
                            Text("Delete")
                                .foregroundColor(.red)
                        }
                        Spacer()
                        Button(action: {
                            UIApplication.shared.windows.filter({$0.isKeyWindow})
                                .first?.rootViewController?
                                .present(UIActivityViewController(activityItems: [model.data.frames[model.data.selected].transform], applicationActivities: nil), animated: true)
                        }) {
                            Text("Share")
                                .foregroundColor(.accentColor)
                        }
                    }
                    HStack {
                        Spacer()
                        HStack(spacing: 30) {
                            ZStack {
                                Button(action: {
                                    if model.data.isStyling {
                                        model.data.isStyling = false
                                    }
                                    if model.data.isAdjusting {
                                        model.data.isAdjusting = false
                                    }
                                    model.data.isBordering = true
                                }) {
                                    Image(systemName: "square.dashed")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .font(.system(size: 22))
                                }
                                .disabled(model.data.isBordering)
                                Circle()
                                    .foregroundColor(.yellow)
                                    .opacity(model.data.isBordering ? 1 : 0)
                                    .frame(width: 5, height: 5)
                                    .padding(.top, 40)
                            }
                            ZStack {
                                Button(action: {
                                    if model.data.isBordering {
                                        model.data.isBordering = false
                                    }
                                    if model.data.isAdjusting {
                                        model.data.isAdjusting = false
                                    }
                                    model.data.isStyling = true
                                }) {
                                    Image(systemName: "cube")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .font(.system(size: 22))
                                }
                                .disabled(model.data.isStyling)
                                Circle()
                                    .foregroundColor(.yellow)
                                    .opacity(model.data.isStyling ? 1 : 0)
                                    .frame(width: 5, height: 5)
                                    .padding(.top, 40)
                            }
                            ZStack {
                                Button(action: {
                                    if model.data.isBordering {
                                        model.data.isBordering = false
                                    }
                                    if model.data.isStyling {
                                        model.data.isStyling = false
                                    }
                                    model.data.isAdjusting = true
                                }) {
                                    Image(systemName: "crop")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .font(.system(size: 22))
                                }
                                .disabled(model.data.isAdjusting)
                                Circle()
                                    .foregroundColor(.yellow)
                                    .opacity(model.data.isAdjusting ? 1 : 0)
                                    .frame(width: 5, height: 5)
                                    .padding(.top, 40)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
            
        }
    }
    
}

struct Frame_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
             Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
