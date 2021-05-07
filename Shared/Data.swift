import SwiftUI

struct Data {
    
    struct Format: Hashable {
        var firstLaunch: Bool
        var showActions: Bool
        var isImporting: Bool
        var isScanning: Bool
        var image: [Int]
        var orientation: String
        var frameSize: String
        var horizontals: [String]
        var verticals: [String]
        var quadrants: [String]
    }
    
    var data: Format = Format(
        firstLaunch: true, // replace with Bool on whether device has launched the app before!
        showActions: false,
        isImporting: false,
        isScanning: false,
        image: [],
        orientation: "vertical",
        frameSize: "",
        horizontals: ["18x13", "20x15", "30x21", "40x30", "45x30", "50x40", "60x45", "70x50", "80x60", "90x60", "100x70"],
        verticals: ["13x18", "15x20", "21x30", "30x40", "30x45", "40x50", "45x60", "50x70", "60x80", "60x90", "70x100"],
        quadrants: ["30x30", "50x50", "70x80"]
    )
    
}
