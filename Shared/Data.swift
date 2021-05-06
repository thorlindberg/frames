import SwiftUI

struct Data {
    
    struct Format: Hashable {
        var firstLaunch: Bool
        var isScanning: Bool
        var orientation: String
        var frameSize: String
    }
    
    var data = Format(
        firstLaunch: !UserDefaults.standard.bool(forKey: "hasLaunchedBefore"),
        isScanning: true,
        orientation: "vertical",
        frameSize: "50x70"
    )
    
}
