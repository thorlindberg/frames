import SwiftUI

struct Welcome: View {
    
    @ObservedObject var model: Model
    @Environment(\.colorScheme) var colorscheme
    
    var body: some View {
        GeometryReader { geometry in
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
                                .padding(.horizontal, -20)
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
                            Text("Beta build 83")
                                .font(.system(size: 18))
                                .opacity(0.5)
                        }
                        .padding(.horizontal, -6)
                        Spacer()
                    }
                    .padding()
                }
                HStack(spacing: 14) {
                    Image(systemName: "bubble.right")
                        .foregroundColor(.accentColor)
                    Link("Contact support", destination: URL(string: "https://thorskjold.com/augmented")!)
                        .accentColor(colorscheme == .dark ? .white : .black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .opacity(0.2)
                }
                Section(header: Text("what's new in this build")) {
                    Text("Added coaching to AR experience")
                        .opacity(0.6)
                    Text("AR objects are now interactive")
                        .opacity(0.6)
                    Text("Frame displayed with interactivity toggle")
                        .opacity(0.6)
                    Text("Welcome sheet accessible through title")
                        .opacity(0.6)
                }
                Section(header: Spacer().frame(height: geometry.size.height - 587)) {
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "beta83")
                        model.data.welcome.toggle()
                    }) {
                        HStack {
                            Spacer()
                            Text(!UserDefaults.standard.bool(forKey: "beta83") ? "Get started" : "Close")
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
    
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome(model: Model())
            .previewDevice("iPhone 8")
    }
}
