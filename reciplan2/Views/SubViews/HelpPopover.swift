import SwiftUI

struct HelpPopover<Content: View>: View {
    let title: String
    let content: () -> Content
    var body: some View {
        Group {
            HStack {
                Label("Help", systemImage: "questionmark.circle").font(.title).foregroundColor(.theme)
                Spacer()
            }.padding()
            
            Text(title).font(.headline).padding(.horizontal)
            content().font(.subheadline).padding()
            
            Spacer()
        }
        .interactionActivityTrackingTag("HelpPopover")
    }
}
