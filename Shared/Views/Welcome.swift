import SwiftUI

struct Welcome: View {
    
    @ObservedObject var model: Model
    
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
                            Text("Beta build 82")
                                .font(.system(size: 18))
                                .opacity(0.5)
                        }
                        .padding(.horizontal, -6)
                        Spacer()
                    }
                    .padding()
                }
                NavigationLink(destination: Browse(model: model)) {
                    Label("Unlock premium", systemImage: "star.fill")
                        .foregroundColor(.purple)
                }
                NavigationLink(destination: Browse(model: model)) {
                    Label("Contact support", systemImage: "bubble.right")
                }
                Section(header:
                            Text("quickstart guide")
                ) {
                    NavigationLink(destination: Browse(model: model)) {
                        Label("Add photo", systemImage: "camera")
                    }
                    NavigationLink(destination: Browse(model: model)) {
                        Label("Customize frame", systemImage: "cube")
                    }
                    NavigationLink(destination: Browse(model: model)) {
                        Label("Augment Reality", systemImage: "move.3d")
                    }
                }
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "beta82")
                    model.data.welcome.toggle()
                }) {
                    HStack {
                        Spacer()
                        Text(!UserDefaults.standard.bool(forKey: "beta82") ? "Get started" : "Close")
                        Spacer()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
    
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Welcome(model: Model())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
