import SwiftUI

struct Welcome: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        NavigationView {
            List {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Image("pear")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 145)
                                .opacity(0.2)
                                .padding(.top, -6)
                                .padding(.horizontal, -16)
                                .padding(.bottom, -100)
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
                                .font(.system(size: 18))
                                .opacity(0.5)
                        }
                        .padding(.horizontal, -6)
                        Spacer()
                    }
                    .padding()
                    /*
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .opacity(0.5)
                                .padding(.top, 4)
                                .padding(.horizontal, -6)
                                .onTapGesture {
                                    UserDefaults.standard.set(true, forKey: "hasLaunched")
                                    model.data.welcome.toggle()
                                }
                        }
                        Spacer()
                    }
                    */
                }
                NavigationLink(destination: Premium()) {
                    Label("Unlock premium", systemImage: "dollarsign.circle")
                        .foregroundColor(.purple)
                }
                NavigationLink(
                    destination: Mail(model: model),
                    isActive: $model.data.isNavigating,
                    label: {
                        Label("Contact support", systemImage: "envelope")
                    }
                )
                .isDetailLink(false) // resource: https://stackoverflow.com/questions/57334455/swiftui-how-to-pop-to-root-view
                Section(header:
                    Text("1. add photo")
                ) {
                    NavigationLink(destination: Import()) {
                        Label("Import from Photos", systemImage: "photo")
                    }
                    NavigationLink(destination: Scan()) {
                        Label("Scan with Camera", systemImage: "viewfinder")
                    }
                }
                Section(header:
                    Text("2. customize frame")
                ) {
                    NavigationLink(destination: Template()) {
                        Label("Photo filters", systemImage: "camera.filters")
                    }
                    NavigationLink(destination: Template()) {
                        Label("Frame materials", systemImage: "cube")
                    }
                    NavigationLink(destination: Template()) {
                        Label("Frame sizes", systemImage: "selection.pin.in.out")
                    }
                }
                Section(header:
                    Text("3. augment reality")
                ) {
                    NavigationLink(destination: Template()) {
                        Label("Hang frame in AR", systemImage: "move.3d")
                    }
                }
                Button(action: {
                    model.data.welcome.toggle()
                }) {
                    HStack {
                        Spacer()
                        Text("Get started")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .padding(.top, -16)
        }
    }
    
}

struct Premium: View {
    
    var body: some View {
        List {
            
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Unlock premium")
    }
    
}

struct Mail: View {
    
    @ObservedObject var model: Data
    
    @State var header: String = "Augmented Frames v.1.0"
    @State var intro: String = "Greetings Thor,"
    @State var text: String = ""
    
    var body: some View {
        List {
            Section(header: Text("topic").padding(.top)) {
                TextField("", text: $header)
                    .disabled(true)
            }
            Section(header: Text("text")) {
                HStack {
                    TextField("", text: $intro)
                        .disabled(true)
                    if text != "" {
                        Text("Reset")
                            .foregroundColor(.red)
                            .onTapGesture {
                                text = ""
                            }
                    }
                }
                TextEditor(text: $text)
            }
            Button(action: {
                text = ""
                model.data.isNavigating = false
            }) {
                HStack {
                    Spacer()
                    Text("Send feedback")
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Contact support")
    }
    
}

struct Import: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        List {
            Section(header: Text("import from photos").padding(.top)) {
                Image(colorscheme == .dark ? "first_dark" : "first")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190, alignment: .top)
                    .padding(.vertical, -6)
                    .padding(.horizontal, -16)
            }
            Section(header: Text("import from photos").padding(.top)) {
                Image(colorscheme == .dark ? "first_dark" : "first")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190, alignment: .top)
                    .padding(.vertical, -6)
                    .padding(.horizontal, -16)
            }
            Section(header: Text("import from photos").padding(.top)) {
                Image(colorscheme == .dark ? "first_dark" : "first")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190, alignment: .top)
                    .padding(.vertical, -6)
                    .padding(.horizontal, -16)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Import from Photos")
    }
    
}

struct Scan: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        List {
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Scan with Camera")
    }
    
}

struct Template: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        List {
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Template")
    }
    
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Welcome(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
