import SwiftUI
import ARKit
import QuickLook

struct QuickLook: View {
    
    @ObservedObject var model: Data
    @State var refresh: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if !refresh {
                    PreviewController(model: model)
                        .ignoresSafeArea()
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Quick Look")
                        .onAppear {
                            model.writeObject()
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        model.data.isQuickLooking.toggle()
                    }) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        refresh.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                refresh.toggle()
                            }
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                /*
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        UIImageWriteToSavedPhotosAlbum(PreviewController(model: model).snapshot(), nil, nil, nil)
                    }) {
                        Image(systemName: "camera")
                    }
                }
                */
            }
        }
    }
    
}

struct QuickLook_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            Window(model: Data())
                .preferredColorScheme($0)
        }
        .previewDevice("iPhone 12 mini")
    }
}

struct PreviewController: UIViewControllerRepresentable {
    
    // resource: https://developer.apple.com/forums/thread/126377
    // resource: https://lostmoa.com/blog/PreviewFilesWithQuickLookInSwiftUI/
    // source: https://github.com/LostMoa/SwiftUI-Code-Examples/blob/main/PreviewFilesWithQuickLookInSwiftUI/SwiftUIQuickLook/PreviewController.swift
    
    @ObservedObject var model: Data
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ controller: QLPreviewController, context: Context) { }

    func makeCoordinator() -> Coordinator { return Coordinator(parent: self) }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: PreviewController
        init(parent: PreviewController) { self.parent = parent }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            let item = ARQuickLookPreviewItem(fileAt: Bundle.main.url(forResource: "object", withExtension: "reality")!) // parent.model.objectPath()
            item.allowsContentScaling = true
            return Bundle.main.url(forResource: "object", withExtension: "txt")! as QLPreviewItem // item
        }
    }
}