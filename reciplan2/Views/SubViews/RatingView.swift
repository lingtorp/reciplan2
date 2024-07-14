import SwiftUI

struct RatingView: View {
    @Bindable var recipe: Recipe
    let interactable: Bool

    private let maximumRating = 5
    private let offImage = Image(systemName: "star")
    private let onImage = Image(systemName: "star.fill")
    private let offColor = Color.gray
    private let onColor = Color.yellow
    
    private func image(for number: Int) -> Image {
        if number > recipe.rating {
            return offImage
        } else {
            return onImage
        }
    }
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack {
            ForEach(1..<maximumRating + 1, id: \.self) { number in
                image(for: number)
                    .foregroundColor(number > recipe.rating ? offColor : onColor)
                    .onTapGesture {
                        hapticFeedback.impactOccurred()
                        recipe.rating = number
                    }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if interactable {
                        let new = max(0, min(Int(gesture.translation.width / 25.0), 5))
                        if new != recipe.rating {
                            hapticFeedback.impactOccurred()
                        }
                        recipe.rating = new
                    }
                }
        )
    }
}
