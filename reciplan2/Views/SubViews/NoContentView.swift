import SwiftUI

struct NoContentView: View {
    // Main text
    let main: String
    // Secondary text (appears on button)
    let secondary: String
    
    var body: some View {
        VStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.red, .blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VisualEffectBlur(blurStyle: .systemUltraThinMaterial, vibrancyStyle: .fill) {
                    VStack(alignment: .center) {
                        Group {
                            Text("🍽️")
                            Text(main).font(.largeTitle).frame(alignment: .bottomLeading)
                            Text(secondary).font(.body)
                        }.foregroundColor(.white).padding()
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(radius: 5)
            .padding()
        }
        .interactionActivityTrackingTag("NoContentView")
    }
}
