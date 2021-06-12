import SwiftUI

struct Welcome: View {
    
    @ObservedObject var model: Data
    @State var tooltip: String = ""
    @State var intro: Bool = true
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Augmented Frames")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .padding(.bottom, 10)
                        Text("Version 1.0.0")
                            .font(.system(size: 20))
                            .opacity(0.5)
                    }
                    Spacer()
                }
                Spacer()
                VStack(spacing: 20) {
                    NavigationLink(destination: First(model: model)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Add photos")
                                    .fontWeight(.bold)
                                Text("And frame them")
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .opacity(0.5)
                        }
                        .frame(height: 40)
                    }
                    Divider()
                    NavigationLink(destination: First(model: model)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Auto-saves your work")
                                    .fontWeight(.bold)
                                Text("Avoid lost work due to crashes")
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .opacity(0.5)
                        }
                        .frame(height: 40)
                    }
                    Divider()
                    NavigationLink(destination: First(model: model)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Exports localization files")
                                    .fontWeight(.bold)
                                Text("Ready for importing into Xcode")
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .opacity(0.5)
                        }
                        .frame(height: 40)
                    }
                }
                Spacer()
                HStack {
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasLaunched")
                        model.data.firstLaunch = false
                    }) {
                        Image(systemName: "cart.fill")
                            .padding(.horizontal)
                    }
                    .buttonStyle(BorderedButtonStyle(tint: .green))
                    Spacer()
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasLaunched")
                        model.data.firstLaunch = false
                    }) {
                        Text("Let's get started")
                            .padding(.horizontal)
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
            }
            .padding(50)
            .navigationBarHidden(true)
        }
    }
    
}

struct First: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        Text("First")
    }
}

struct Second: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        Text("Second")
    }
}

struct Third: View {
    
    @ObservedObject var model: Data
    
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
