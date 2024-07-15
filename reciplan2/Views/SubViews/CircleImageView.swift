import SwiftUI

struct CircleRecipeImageView: View {
    let data: Data?
    var body: some View {
        GeometryReader { geo in
            let Mw = geo.size.width
            let mw = geo.size.width * 0.95
            let Mh = Mw
            let mh = mw
            if let data = data,
               let image = UIImage(data: data) {
                ZStack {
                    // Background ring
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
                        .frame(width: Mw, height: Mh)
                        .scaledToFit()
                        .blur(radius: 32)
                        .clipShape(Circle()).shadow(radius: 5)

                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
                        .frame(width: mw, height: mh)
                        .opacity(0.8)
                        .scaledToFit()
                        .clipShape(Circle()).shadow(radius: 5)
                }
            } else {
                ZStack {
                    // Background ring
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .red]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: Mw, height: Mh)
                    .scaledToFit()
                    .blur(radius: 32)
                    .clipShape(Circle()).shadow(radius: 5)
                    
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .red]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: mw, height: mh)
                    .opacity(0.8)
                    .scaledToFit()
                    .clipShape(Circle()).shadow(radius: 5)
                }
            }
        }
    }
}
