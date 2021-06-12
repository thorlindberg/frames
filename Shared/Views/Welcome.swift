import SwiftUI

struct Welcome: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        if model.data.purchase {
            NavigationView {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Unlock extra features")
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                                .padding(.bottom, 15)
                            Text("One-time purchase")
                                .font(.system(size: 20))
                                .opacity(0.5)
                        }
                        Spacer()
                    }
                    Spacer()
                    VStack(spacing: 30) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Create custom collages")
                                    .fontWeight(.bold)
                                Text("Subtext")
                            }
                            Spacer()
                        }
                        .frame(height: 40)
                        Divider()
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Create custom collages")
                                    .fontWeight(.bold)
                                Text("Subtext")
                            }
                            Spacer()
                        }
                        .frame(height: 40)
                        Divider()
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Create custom collages")
                                    .fontWeight(.bold)
                                Text("Subtext")
                            }
                            Spacer()
                        }
                        .frame(height: 40)
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            model.data.purchase = false
                        }) {
                            Text("No")
                                .padding(.horizontal)
                        }
                        .buttonStyle(BorderedButtonStyle())
                        Spacer()
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "hasLaunched")
                            model.data.welcome = false
                        }) {
                            Text("Purchase for $1")
                                .padding(.horizontal)
                        }
                        .buttonStyle(BorderedButtonStyle(tint: .purple))
                    }
                }
                .padding(50)
                .navigationBarHidden(true)
            }
            .transition(.move(edge: .leading).combined(with: .opacity))
        } else {
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
                                    Text("First")
                                        .fontWeight(.bold)
                                    Text("Subtext")
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
                                    Text("Second")
                                        .fontWeight(.bold)
                                    Text("Subtext")
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
                                    Text("Third")
                                        .fontWeight(.bold)
                                    Text("Subtext")
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
                            model.data.purchase = true
                        }) {
                            Image(systemName: "bolt.fill")
                                .padding(.horizontal)
                        }
                        .buttonStyle(BorderedButtonStyle(tint: .purple))
                        Spacer()
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "hasLaunched")
                            model.data.welcome = false
                        }) {
                            Text("Understood")
                                .padding(.horizontal)
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                }
                .padding(50)
                .navigationBarHidden(true)
            }
            .transition(.move(edge: .leading).combined(with: .opacity))
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
