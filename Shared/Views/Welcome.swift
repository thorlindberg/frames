import SwiftUI

struct Welcome: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Augmented Frames")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .padding(.bottom, 15)
                        Text("Version 1.0")
                            .font(.system(size: 20))
                            .opacity(0.5)
                    }
                    Spacer()
                }
                Spacer()
                VStack(spacing: 30) {
                    NavigationLink(destination: First()) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Import or scan photos")
                                    .fontWeight(.bold)
                                Text("and edit to your liking ")
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .opacity(0.5)
                        }
                        .frame(height: 40)
                    }
                    Divider()
                    NavigationLink(destination: Second()) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Customize your frame")
                                    .fontWeight(.bold)
                                Text("with materials and filters")
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .opacity(0.5)
                        }
                        .frame(height: 40)
                    }
                    Divider()
                    NavigationLink(destination: Third()) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("View in Augmented Reality")
                                    .fontWeight(.bold)
                                Text("with realistic sizing")
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .opacity(0.5)
                        }
                        .frame(height: 40)
                    }
                }
                Spacer()
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "hasLaunched")
                    model.data.welcome = false
                }) {
                    ZStack {
                        Capsule()
                            .frame(height: 40)
                            .foregroundColor(.accentColor)
                            .opacity(colorscheme == .dark ? 0.1 : 0.05)
                        Text("Get started")
                            .padding(.horizontal)
                    }
                }
                // .buttonStyle(BorderedButtonStyle())
            }
            .padding(50)
            .navigationBarHidden(true)
        }
    }
    
}

struct First: View {
    var body: some View {
        Text("First")
    }
}

struct Second: View {
    var body: some View {
        Text("Second")
    }
}

struct Third: View {
    var body: some View {
        Text("Third")
    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
