import SwiftUI

struct Welcome: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Image("pear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 210)
                            .opacity(0.1)
                    }
                    Spacer()
                }
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
                        model.data.welcome.toggle()
                    }) {
                        ZStack {
                            Capsule()
                                .frame(height: 40)
                                .foregroundColor(.accentColor)
                                .opacity(colorscheme == .dark ? 0.1 : 0.05)
                            Text(!UserDefaults.standard.bool(forKey: "hasLaunched") ? "Get started" : "Close")
                                .padding(.horizontal)
                        }
                    }
                    // .buttonStyle(BorderedButtonStyle())
                }
                .padding(40)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
            }
        }
    }
    
}

struct First: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        VStack(spacing: 0) {
            Image(colorscheme == .dark ? "first_dark" : "first")
                .resizable()
                .scaledToFill()
                .frame(height: 190, alignment: .top)
                .clipped()
                .brightness(-0.1)
                .padding(.top, -20)
            Divider()
            List {
                Section(header: Label("Import from Photos", systemImage: "photo").padding(.top)) {
                    HStack {
                        Text("1. Click")
                        Image(systemName: "camera")
                        Text("to add a photo")
                    }
                    HStack {
                        Text("2. Click")
                        Image(systemName: "photo")
                        Text("to import from Photos")
                    }
                    Text("3. Select a photo to import it")
                }
                Section(header: Label("Scan with Camera", systemImage: "viewfinder")) {
                    HStack {
                        Text("1. Click")
                        Image(systemName: "camera")
                        Text("to add a photo")
                    }
                    HStack {
                        Text("2. Click")
                        Image(systemName: "viewfinder")
                        Text("to scan with Camera")
                    }
                    HStack {
                        Text("3. Click")
                        Image(systemName: "record.circle")
                        Text("to scan a photo")
                    }
                    HStack {
                        Text("4. Click")
                        Text("Save")
                            .bold()
                        Text("to use the scanned photo")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("Import or scan")
    }
    
}

struct Second: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        Text("Second")
            .navigationBarTitle("Customization")
    }
    
}

struct Third: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        Text("Third")
            .navigationBarTitle("Augmented Reality")
    }
    
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 8")
    }
}
