import SwiftUI

struct ScrollStack: View {
    
    // input properties
    
    var direction: Edge.Set
    var items: Array<Int> // removed in final iteration
    var size: CGFloat
    var spacing: CGFloat
    @Binding var selection: Int
    
    // computed properties
    
    var contentWidth: CGFloat {
        CGFloat(items.count) * size + CGFloat(items.count - 1) * spacing
    }
    var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    var initialOffset: CGFloat {
        (contentWidth/2.0) - (screenWidth/2.0) + ((screenWidth - size) / 2.0)
    }
    
    // states
    
    @State var scrollOffset: CGFloat = 0
    @State var dragOffset: CGFloat = 0
    
    var body: some View {
        
        HStack(spacing: spacing) {
            ForEach(items.indices, id: \.self) { item in
                Image("sample")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size)
                    .opacity(item == selection ? 1 : 0.5)
            }
        }
        .onAppear {
            scrollOffset = initialOffset // removed in final iteration
        }
        .offset(x: scrollOffset + dragOffset, y: 0)
        .gesture(
            DragGesture()
                .onChanged({ event in
                    dragOffset = event.translation.width
                })
                .onEnded({ event in
                    
                    // Scroll to where user dragged
                    scrollOffset += event.translation.width
                    dragOffset = 0
                    
                    // Now calculate which item to snap to
                    let contentWidth: CGFloat = CGFloat(items.count) * size + CGFloat(items.count - 1) * spacing
                    let screenWidth = UIScreen.main.bounds.width
                    
                    // Center position of current offset
                    let center = scrollOffset + (screenWidth / 2.0) + (contentWidth / 2.0)
                    
                    // Calculate which item we are closest to using the defined size
                    var index = (center - (screenWidth / 2.0)) / (size + spacing)
                    
                    // Should we stay at current index or are we closer to the next item...
                    if index.remainder(dividingBy: 1) > 0.5 {
                        index += 1
                    } else {
                        index = CGFloat(Int(index))
                    }
                    
                    // Protect from scrolling out of bounds
                    index = min(index, CGFloat(items.count) - 1)
                    index = max(index, 0)
                    
                    // Set final offset (snapping to item)
                    let newOffset = index * size + (index - 1) * spacing - (contentWidth / 2.0) + (screenWidth / 2.0) - ((screenWidth - size) / 2.0) + spacing
                    
                    // Animate snapping
                    withAnimation {
                        scrollOffset = newOffset
                    }
                    
                    // Update selection
                    withAnimation {
                        selection = items.count - Int(index) - 1
                        print(Int(index))
                    }
                    
                })
        )
        
    }
    
}

struct Temp: View {
    
    @State var selection: Int = 0
    
    var body: some View {
        ScrollStack(
            direction: .horizontal,
            items: [0, 1, 2, 3, 4],
            size: 250,
            spacing: 20,
            selection: $selection
        )
        .previewDevice("iPhone 12 mini")
    }
    
}

struct ScrollStack_Previews: PreviewProvider {
    static var previews: some View {
        Temp()
            .previewDevice("iPhone 12 mini")
    }
}
