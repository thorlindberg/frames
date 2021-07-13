import SwiftUI

struct Welcome: View {
    
    @ObservedObject var model: Data
    @Environment(\.colorScheme) var colorscheme
    @State var frames: [Data.Frame] = []
    
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
                    Label("Unlock premium", systemImage: "star.fill")
                        .foregroundColor(.purple)
                }
                NavigationLink(destination: Contact(model: model)) {
                    Label("Contact support", systemImage: "bubble.right")
                }
                Section(header:
                            Text("quickstart guide")
                ) {
                    NavigationLink(destination: First(model: model)) {
                        Label("Add photo", systemImage: "camera")
                    }
                    NavigationLink(destination: Second(model: model)) {
                        Label("Customize frame", systemImage: "cube")
                    }
                    NavigationLink(destination: Third(model: model)) {
                        Label("Augment Reality", systemImage: "move.3d")
                    }
                }
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "v1.0")
                    model.data.frames = frames
                    model.data.welcome.toggle()
                }) {
                    HStack {
                        Spacer()
                        Text(!UserDefaults.standard.bool(forKey: "v1.0") ? "Get started" : "Close")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .onAppear {
            model.toggleAdjust()
            model.data.isStyling = true
            frames = model.data.frames
            model.data.frames = [Data.Frame(
                image: UIImage(imageLiteralResourceName: "sample"),
                transform: UIImage(imageLiteralResourceName: "sample"),
                size: Data.Size(width: 60, height: 90), border: 0.05, filter: "None", material: "Oak"
            )]
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

struct Contact: View {
    
    @ObservedObject var model: Data
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                Section {
                    Picker(
                        selection: Binding(
                            get: { model.data.feedback.category },
                            set: {
                                model.data.feedback.category = $0
                                model.data.feedback.issue = ""
                                model.data.feedback.description = ""
                                model.data.feedback.email = ""
                            }
                        ),
                        label: HStack {
                            Text("Select a category")
                            Spacer()
                            Image(systemName: "rectangle.grid.2x2")
                        }
                        .opacity(0.3)
                    ) {
                        Label("Error report", systemImage: "exclamationmark.triangle")
                            .tag("Error report")
                        Label("Refund purchase", systemImage: "cart")
                            .tag("Refund purchase")
                        Label("Feature request", systemImage: "wand.and.stars")
                            .tag("Feature request")
                    }
                    .pickerStyle(InlinePickerStyle())
                }
                if !model.data.feedback.category.isEmpty {
                    Section {
                        if model.data.feedback.category == "Error report" {
                            Picker(
                                selection: $model.data.feedback.issue,
                                label: HStack {
                                    Text("Select an issue")
                                    Spacer()
                                    Image(systemName: "exclamationmark.triangle")
                                }
                                .opacity(0.3)
                            ) {
                                Text("Application crashes")
                                    .tag("Application crashes")
                                Text("Slow performance")
                                    .tag("Slow performance")
                                Text("Interface glitches")
                                    .tag("Interface glitches")
                            }
                            .pickerStyle(InlinePickerStyle())
                        }
                        if model.data.feedback.category == "Refund purchase" {
                            Picker(
                                selection: $model.data.feedback.issue,
                                label: HStack {
                                    Text("Select a reason")
                                    Spacer()
                                    Image(systemName: "cart")
                                }
                                .opacity(0.3)
                            ) {
                                Text("Purchased by mistake")
                                    .tag("Purchased by mistake")
                            }
                            .pickerStyle(InlinePickerStyle())
                        }
                    }
                }
                if !model.data.feedback.issue.isEmpty || model.data.feedback.category == "Feature request" {
                    if model.data.feedback.category == "Refund purchase" {
                        Section {
                            HStack {
                                Text("Your email")
                                    .opacity(0.3)
                                Spacer()
                                if model.data.feedback.focus != "email" {
                                    Image(systemName: "envelope")
                                        .opacity(0.3)
                                } else {
                                    Text("Done")
                                        .foregroundColor(.blue)
                                        .bold()
                                        .onTapGesture {
                                            UIApplication.shared.endEditing()
                                            if !textFieldValidatorEmail(model.data.feedback.email) {
                                                model.data.feedback.invalid = true
                                            }
                                        }
                                }
                            }
                            TextField(
                                "JohnAppleseed@icloud.com",
                                text: $model.data.feedback.email,
                                onEditingChanged: { focused in
                                    model.data.feedback.invalid = false
                                    model.data.feedback.focus = focused ? "email" : ""
                                }
                            )
                            .keyboardType(.twitter)
                            .autocapitalization(.none)
                            .foregroundColor(model.data.feedback.invalid ? .red : nil)
                        }
                    }
                    if model.data.feedback.category != "Refund purchase" || model.data.feedback.category == "Refund purchase" && textFieldValidatorEmail(model.data.feedback.email) {
                        Section {
                            HStack {
                                if model.data.feedback.category == "Error report" {
                                    Text("Describe the issue (optional)")
                                        .opacity(0.3)
                                }
                                if model.data.feedback.category == "Refund purchase" {
                                    Text("Additional comments (optional)")
                                        .opacity(0.3)
                                }
                                if model.data.feedback.category == "Feature request" {
                                    Text("Describe the request")
                                        .opacity(0.3)
                                }
                                Spacer()
                                if model.data.feedback.focus != "comment" {
                                    Image(systemName: "square.and.pencil")
                                        .opacity(0.3)
                                } else {
                                    Text("Done")
                                        .foregroundColor(.blue)
                                        .bold()
                                        .onTapGesture {
                                            UIApplication.shared.endEditing()
                                        }
                                }
                            }
                            TextField(
                                "Description",
                                text: $model.data.feedback.description,
                                onEditingChanged: { focused in
                                    model.data.feedback.focus = focused ? "comment" : ""
                                }
                            )
                            .keyboardType(.twitter)
                            .autocapitalization(.none)
                        }
                        if model.data.feedback.category == "Refund purchase" {
                            Section(header: Text("refunds take 3-5 business days")) {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                    model.data.feedback.success = true
                                }) {
                                    HStack {
                                        Spacer()
                                        Text("Request refund")
                                            .foregroundColor(.blue)
                                        Spacer()
                                    }
                                }
                                .alert(isPresented: $model.data.feedback.success) {
                                    Alert(
                                        title: Text("Refund requested"),
                                        message: Text("You will receive a response via email"),
                                        dismissButton: Alert.Button.default(
                                            Text("OK"),
                                            action: {
                                                presentationMode.wrappedValue.dismiss()
                                                model.data.feedback = model.feedbackreset
                                            }
                                        )
                                    )
                                }
                            }
                            .id("send")
                            .onAppear {
                                withAnimation {
                                    proxy.scrollTo("send", anchor: .top)
                                }
                            }
                        } else {
                            Section {
                                Button(action: {
                                    model.data.feedback.success.toggle()
                                }) {
                                    HStack {
                                        Spacer()
                                        Text("Send feedback")
                                            .foregroundColor(.blue)
                                        Spacer()
                                    }
                                }
                                .alert(isPresented: $model.data.feedback.success) {
                                    Alert(
                                        title: Text("Feedback sent"),
                                        message: Text("Thank you for helping us improve!"),
                                        dismissButton: Alert.Button.default(
                                            Text("OK"),
                                            action: {
                                                presentationMode.wrappedValue.dismiss()
                                                model.data.feedback = model.feedbackreset
                                            }
                                        )
                                    )
                                }
                            }
                            .id("send")
                            .onAppear {
                                withAnimation {
                                    proxy.scrollTo("send", anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Contact support")
        }
    }
    
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct First: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                Section(header:
                            Text("tap camera and select an option")
                            .padding(.top)
                ) {
                    ZStack {
                        HStack {
                            Menu {
                                Button(action: {
                                    withAnimation {
                                        model.data.guide = "import"
                                    }
                                }) {
                                    Label("Import from Photos", systemImage: "photo")
                                }
                                Button(action: {
                                    withAnimation {
                                        model.data.guide = "scan"
                                    }
                                }) {
                                    Label("Scan with Camera", systemImage: "viewfinder")
                                }
                                .disabled(true) // needs to be implemented first
                            } label: {
                                Image(systemName: "camera.fill")
                            }
                            Spacer()
                            Text("AR")
                                .bold()
                                .opacity(0.2)
                            
                        }
                        HStack {
                            Spacer()
                            Text("Augmented Frames")
                                .bold()
                                .opacity(0.2)
                            Spacer()
                        }
                    }
                    Frame(model: model)
                        .frame(height: 420)
                        .padding(.vertical, -6)
                        .padding(.horizontal, -16)
                        .opacity(0.2)
                }
                if model.data.guide == "import" {
                    Section(header:
                                Text("tap a photo to import it")
                    ) {
                        Text("Close")
                            .onTapGesture {
                                withAnimation {
                                    model.data.guide = ""
                                }
                            }
                        ImagePicker(model: model)
                            .frame(height: 530)
                            .padding(.top, -115)
                            .padding(.bottom, -6)
                            .padding(.horizontal, -16)
                    }
                    .id("import")
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo("import", anchor: .top)
                        }
                    }
                }
                if model.data.guide == "scan" {
                    Section(header:
                                Text("tap the record button to scan")
                    ) {
                        Text("Close")
                            .onTapGesture {
                                withAnimation {
                                    model.data.guide = ""
                                }
                            }
                        ImagePicker(model: model)
                            .frame(height: 530)
                            .padding(.top, -115)
                            .padding(.bottom, -6)
                            .padding(.horizontal, -16)
                    }
                    .id("scan")
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo("scan", anchor: .top)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Add photo")
            .onDisappear {
                model.data.guide = ""
            }
        }
    }
    
}

struct Second: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        List {
            Section(header:
                        Text("use the center menu to customize")
                        .padding(.top)
            ) {
                ZStack {
                    HStack {
                        Image(systemName: "camera.fill")
                        Spacer()
                        Text("AR")
                            .bold()
                    }
                    HStack {
                        Spacer()
                        Text("Augmented Frames")
                            .bold()
                        Spacer()
                    }
                }
                .opacity(0.2)
                Frame(model: model)
                    .frame(height: 420)
                    .padding(.vertical, -6)
                    .padding(.horizontal, -16)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Customize frame")
        .onAppear {
            model.data.guide = "customize"
        }
        .onDisappear {
            model.data.guide = ""
        }
    }
    
}

struct Third: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                Section(header:
                            Text("tap ar to hang a framed photo")
                            .padding(.top)
                ) {
                    ZStack {
                        HStack {
                            Image(systemName: "camera.fill")
                                .opacity(0.2)
                            Spacer()
                            Text("AR")
                                .bold()
                                .onTapGesture {
                                    withAnimation {
                                        model.data.guide = "augment"
                                    }
                                }
                        }
                        HStack {
                            Spacer()
                            Text("Augmented Frames")
                                .bold()
                                .opacity(0.2)
                            Spacer()
                        }
                    }
                    Frame(model: model)
                        .frame(height: 420)
                        .padding(.vertical, -6)
                        .padding(.horizontal, -16)
                        .opacity(0.2)
                }
                if model.data.guide == "augment" {
                    Section(header:
                                Text("point your device at a wall")
                    ) {
                        HStack {
                            Text("Close")
                                .onTapGesture {
                                    withAnimation {
                                        model.data.guide = ""
                                    }
                                }
                            Spacer()
                            HStack {
                                Text("Flash")
                                    .if (model.data.isFlashlight) { view in
                                        view.bold()
                                    }
                                Image(systemName: model.data.isFlashlight ? "bolt.fill" : "bolt.slash")
                            }
                            .onTapGesture {
                                model.data.isFlashlight.toggle()
                                toggleTorch(on: model.data.isFlashlight)
                            }
                        }
                        ARViewContainer(model: model)
                            .frame(height: 420)
                            .padding(.vertical, -6)
                            .padding(.horizontal, -16)
                    }
                    .id("augment")
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo("augment", anchor: .top)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Augment Reality")
            .onDisappear {
                model.data.guide = ""
            }
        }
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
