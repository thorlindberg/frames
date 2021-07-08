import SwiftUI

struct Welcome: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header:
                        Label("add photo", systemImage: "camera")
                            .padding(.top, 230)
                    ) {
                        NavigationLink(destination: First()) {
                            Text("Import from Photos")
                        }
                        NavigationLink(destination: First()) {
                            Text("Scan with Camera")
                        }
                    }
                    Section(header:
                        Label("customize frame", systemImage: "cube")
                    ) {
                        NavigationLink(destination: Second()) {
                            Text("Photo filters")
                        }
                        NavigationLink(destination: Second()) {
                            Text("Frame materials")
                        }
                        NavigationLink(destination: Second()) {
                            Text("Frame sizes")
                        }
                    }
                    Section(header:
                        Label("augment reality", systemImage: "eye")
                    ) {
                        NavigationLink(destination: Third()) {
                            Text("Hang frame in AR")
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Image("pear")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                .opacity(0.1)
                        }
                        Spacer()
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Augmented Frames")
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                            Text("Version 1.0")
                                .font(.system(size: 20))
                                .opacity(0.5)
                            Spacer()
                        }
                        Spacer()
                        VStack {
                            Button(action: {
                                UserDefaults.standard.set(true, forKey: "hasLaunched")
                                model.data.welcome.toggle()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 30))
                                    .opacity(0.2)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
    
}

struct First: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        List {
            Section(header: Label("Import from Photos", systemImage: "photo").padding(.top)) {
                Image(colorscheme == .dark ? "first_dark" : "first")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190, alignment: .top)
                    .padding(.vertical, -6)
                    .padding(.horizontal, -16)
            }
            Section(header: Label("Import from Photos", systemImage: "photo").padding(.top)) {
                Image(colorscheme == .dark ? "first_dark" : "first")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190, alignment: .top)
                    .padding(.vertical, -6)
                    .padding(.horizontal, -16)
            }
            Section(header: Label("Import from Photos", systemImage: "photo").padding(.top)) {
                Image(colorscheme == .dark ? "first_dark" : "first")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190, alignment: .top)
                    .padding(.vertical, -6)
                    .padding(.horizontal, -16)
            }
            /*
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
            */
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Add photo")
    }
    
}

struct Second: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        Text("Second")
            .navigationBarTitle("Customize frames")
    }
    
}

struct Third: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        Text("Third")
            .navigationBarTitle("Augment Reality")
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
