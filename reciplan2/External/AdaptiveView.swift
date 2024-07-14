// Source: https://www.hackingwithswift.com/quick-start/swiftui/how-to-automatically-switch-between-hstack-and-vstack-based-on-size-class
// On iOS switches from VStack to HStack and vice versa depending on the current size class
// On watchOS this is the compact VStack
import SwiftUI

struct AdaptiveStack<Content: View>: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    init(horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        Group {
            #if os(iOS)
            HStack(alignment: verticalAlignment, spacing: spacing, content: content)

            /*
             // IMPROVE: Always .compact for some reason when it shouldnt be
            if sizeClass == .compact {
                VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
            } else {
                HStack(alignment: verticalAlignment, spacing: spacing, content: content)
            }*/
            #elseif os(watchOS)
            HStack(alignment: verticalAlignment, spacing: spacing, content: content)
            #endif
        }
    }
}
