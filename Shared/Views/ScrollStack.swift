import SwiftUI

struct ScrollStack<Content: View>: View {
    
    // input properties
    var items: Int
    var direction: Edge.Set = .horizontal
    var size: CGFloat = 280
    var spacing: CGFloat = 28
    @Binding var selection: Int
    @ViewBuilder var content: Content
    
    // computed properties
    var contentSize: CGFloat {
        CGFloat(items) * size + CGFloat(items - 1) * spacing
    }
    var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    var initialOffset: CGFloat {
        if direction == .horizontal {
            return (contentSize/2.0) - (screenWidth/2.0) + ((screenWidth - size) / 2.0)
        } else {
            return (contentSize/2.0) - (screenHeight/2.0) + ((screenHeight - size) / 2.0)
        }
    }
    
    // states
    @State var scrollOffset: CGFloat = 0
    @State var dragOffset: CGFloat = 0
    
    var body: some View {
        
        ZStack {
            if direction == .horizontal {
                HStack(spacing: spacing) {
                    content
                }
            } else {
                VStack(spacing: spacing) {
                    content
                }
            }
        }
        .onAppear {
            scrollOffset = initialOffset
        }
        .offset(x: direction == .horizontal ? scrollOffset + dragOffset : 0, y: direction == .horizontal ? 0 : scrollOffset + dragOffset)
        .onChange(of: selection, perform: { _ in
            // Provide haptic feedback
            UIImpactFeedbackGenerator(style: .heavy)
                .impactOccurred()
        })
        .gesture(
            DragGesture()
                .onChanged({ event in
                    dragOffset = direction == .horizontal ? event.translation.width : event.translation.height
                })
                .onEnded({ event in
                    
                    if direction == .horizontal {
                        
                        // Scroll to where user dragged
                        scrollOffset += event.translation.width
                        dragOffset = 0
                        
                        // Now calculate which item to snap to
                        let contentSize: CGFloat = CGFloat(items) * size + CGFloat(items - 1) * spacing
                        let screenWidth = UIScreen.main.bounds.width
                        
                        // Center position of current offset
                        let center = scrollOffset + (screenWidth / 2.0) + (contentSize / 2.0)
                        
                        // Calculate which item we are closest to using the defined size
                        var index = (center - (screenWidth / 2.0)) / (size + spacing)
                        
                        // Should we stay at current index or are we closer to the next item...
                        if index.remainder(dividingBy: 1) > 0.5 {
                            index += 1
                        } else {
                            index = CGFloat(Int(index))
                        }
                        
                        // Protect from scrolling out of bounds
                        index = min(index, CGFloat(items) - 1)
                        index = max(index, 0)
                        
                        // Set final offset (snapping to item)
                        let newOffset = index * size + (index - 1) * spacing - (contentSize / 2.0) + (screenWidth / 2.0) - ((screenWidth - size) / 2.0) + spacing
                        
                        // Animate snapping
                        withAnimation {
                            scrollOffset = newOffset
                        }
                        
                        // Update selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.27) {
                            withAnimation {
                                selection = items - Int(index) - 1
                            }
                        }
                        
                    } else {
                        
                        // Scroll to where user dragged
                        scrollOffset += event.translation.height
                        dragOffset = 0
                        
                        // Now calculate which item to snap to
                        let contentSize: CGFloat = CGFloat(items) * size + CGFloat(items - 1) * spacing
                        let screenHeight = UIScreen.main.bounds.height
                        
                        // Center position of current offset
                        let center = scrollOffset + (screenHeight / 2.0) + (contentSize / 2.0)
                        
                        // Calculate which item we are closest to using the defined size
                        var index = (center - (screenHeight / 2.0)) / (size + spacing)
                        
                        // Should we stay at current index or are we closer to the next item...
                        if index.remainder(dividingBy: 1) > 0.5 {
                            index += 1
                        } else {
                            index = CGFloat(Int(index))
                        }
                        
                        // Protect from scrolling out of bounds
                        index = min(index, CGFloat(items) - 1)
                        index = max(index, 0)
                        
                        // Set final offset (snapping to item)
                        let newOffset = index * size + (index - 1) * spacing - (contentSize / 2.0) + (screenHeight / 2.0) - ((screenHeight - size) / 2.0) + spacing
                        
                        // Animate snapping
                        withAnimation {
                            scrollOffset = newOffset
                        }
                        
                        // Update selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.27) {
                            withAnimation {
                                selection = items - Int(index) - 1
                            }
                        }
                        
                    }
                    
                })
        )
        
    }
    
}
