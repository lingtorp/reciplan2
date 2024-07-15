import SwiftUI

struct RecipeListCell: View {
    @Environment(\.cookingTimeFormatter) private var cookingTimeFormatter: MeasurementFormatter
    @Environment(\.horizontalSizeClass) var sizeClass
    var recipe: Recipe
    
    var body: some View {
        HStack {
            CircleRecipeImageView(data: recipe.image).frame(maxWidth: 100.0, maxHeight: 100.0).scaledToFit()
            VStack(alignment: .leading) {
                HStack {
                    Text(recipe.name).allowsTightening(true).lineLimit(1).font(.headline).minimumScaleFactor(0.5)
                    VStack(alignment: .trailing) {
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.right").font(.headline).foregroundColor(.theme)
                        }
                    }.layoutPriority(-3)
                }.layoutPriority(-2)
                Text(recipe.headline).foregroundColor(.secondary).font(.subheadline).allowsTightening(true).lineLimit(2)
                HStack {
                    RecipeRatingView(rating: recipe.rating)
                    if recipe.cookingTimeMinutes > 0 {
                        Divider().frame(maxHeight: 10)
                        Label("\(recipe.cookingTimeMinutes) " + cookingTimeFormatter.string(from: UnitDuration.minutes), systemImage: "clock")
                    }
                    RecipeHeartView(favorite: recipe.favorite)
                }.font(.footnote).foregroundColor(.gray)
            }
        }
        .contentShape(Rectangle()) // NOTE: Entire view is tappable even the space between views
    }
}
