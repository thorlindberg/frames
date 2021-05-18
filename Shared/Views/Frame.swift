import SwiftUI
import SceneKit

struct Frame: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
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
                VStack(spacing: 0) {
                    Spacer()
                    Divider()
                    VStack(spacing: 0) {
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
                        if model.data.isFiltering {
                            ScrollView(.horizontal) {
                                HStack {
                                    Image(uiImage: model.data.frames[model.data.selected].transform)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                    Image(uiImage: model.data.frames[model.data.selected].transform)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .saturation(0)
                                        .frame(width: 50, height: 50)
                                    Image(uiImage: model.data.frames[model.data.selected].transform)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .colorInvert()
                                        .frame(width: 50, height: 50)
                                    Image(uiImage: model.data.frames[model.data.selected].transform)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .brightness(-0.2)
                                        .frame(width: 50, height: 50)
                                    Image(uiImage: model.data.frames[model.data.selected].transform)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .brightness(0.2)
                                        .frame(width: 50, height: 50)
                                }
                            }
                            .padding()
                        }
                        if model.data.isAdjusting {
                            ScrollView(.horizontal) {
                                HStack {
                                    Text("10:30")
                                    Text("20:30")
                                    Text("50:70")
                                }
                            }
                            .padding()
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
                                            if model.data.isFiltering {
                                                model.data.isFiltering = false
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
                                            model.data.isFiltering = true
                                        }) {
                                            Image(systemName: "camera.filters")
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                                .font(.system(size: 22))
                                        }
                                        .disabled(model.data.isFiltering)
                                        Circle()
                                            .foregroundColor(.yellow)
                                            .opacity(model.data.isFiltering ? 1 : 0)
                                            .frame(width: 5, height: 5)
                                            .padding(.top, 40)
                                    }
                                    ZStack {
                                        Button(action: {
                                            if model.data.isBordering {
                                                model.data.isBordering = false
                                            }
                                            if model.data.isFiltering {
                                                model.data.isFiltering = false
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
                        .padding(.bottom, 35)
                    }
                    .background(BlurView())
                }
                .ignoresSafeArea()
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
