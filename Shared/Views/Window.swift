import SwiftUI

struct Window: View {
    
    @ObservedObject var model: Data
    
    var body: some View {
        NavigationView {
            Frame(model: model)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $model.data.isImporting) {
            ImagePicker(model: model)
        }
        .sheet(isPresented: $model.data.isAugmenting) {
            Augment(model: model)
                .modifier(DisableModalDismiss(disabled: true))
        }
        .sheet(isPresented: $model.data.firstLaunch) {
            Welcome(model: model)
                .modifier(DisableModalDismiss(disabled: true))
        }
    }
    
}

struct Window_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}
