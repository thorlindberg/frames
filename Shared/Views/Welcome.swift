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
                    Text("quickstart guide")
                            .padding(.top)
                ) {
                    NavigationLink(destination: First()) {
                        Label("Add photo", systemImage: "camera")
                    }
                    NavigationLink(destination: Second()) {
                        Label("Customize frame", systemImage: "cube")
                    }
                    NavigationLink(destination: Third()) {
                        Label("Augment Reality", systemImage: "move.3d")
                    }
                }
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "hasLaunched")
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

struct First: View {
    
    @Environment(\.colorScheme) var colorscheme
    @State var selection: Int = 1
    
    var body: some View {
        VStack(spacing: 0) {
            Picker(selection: $selection, label: Text("")) {
                Text("Import").tag(1)
                Text("Scan").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Divider()
            List {
                if selection == 1 {
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
                if selection == 2 {
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("Add photo")
    }
    
}

struct Second: View {
    
    @Environment(\.colorScheme) var colorscheme
    @State var selection: Int = 2
    
    var body: some View {
        VStack(spacing: 0) {
            Picker(selection: $selection, label: Text("")) {
                Text("Filters").tag(1)
                Text("Materials").tag(2)
                Text("Sizes").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Divider()
            List {
                if selection == 1 {
                }
                if selection == 2 {
                }
                if selection == 3 {
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("Customize frame")
    }
    
}

struct Third: View {
    
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        List {
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Augment Reality")
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
