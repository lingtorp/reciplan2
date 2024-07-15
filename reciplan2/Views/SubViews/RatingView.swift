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

struct RecipeRatingView: View {
    @Environment(\.colorScheme) var colorScheme
    let rating: Int
    var body: some View {
        let img = rating > 0 ? "star.leadinghalf.filled" : "star"
        let fade = colorScheme == .light ? 5.0 : Double(rating)
        Label("\(rating)", systemImage: img).foregroundColor(rating != 0 ? .yellow : .gray).saturation(0.2 * fade)
    }
}

struct RecipeHeartView: View {
    let favorite: Bool
    var body: some View {
        if favorite {
            Divider().frame(maxHeight: 10)
            Image(systemName: "heart.fill").foregroundColor(.red)
        }
    }
}

struct FilterView: View {
    @Binding var filter: Filter
    @Binding var onlyFavorites: Bool
    var body: some View {
        Menu {
            Section {
                Picker("Sort by", selection: $filter) {
                    Label(Filter.alphabetical.localized,        systemImage: "abc").tag(Filter.alphabetical)
                    Label(Filter.inverseAlphabetical.localized, systemImage: "abc").tag(Filter.inverseAlphabetical)
                    Label(Filter.newestFirst.localized,         systemImage: "clock").tag(Filter.newestFirst)
                    Label(Filter.oldestFirst.localized,         systemImage: "clock.fill").tag(Filter.oldestFirst)
                    Label(Filter.highestRated.localized,        systemImage: "star.fill").tag(Filter.highestRated)
                    Label(Filter.lowestRated.localized,         systemImage: "star").tag(Filter.lowestRated)
                }
            }
            
            Toggle(isOn: $onlyFavorites) {
                Label("Favorites only", systemImage: onlyFavorites ? "heart.fill" : "heart")
            }
        } label: {
            Label("Sort by", systemImage: "arrow.up.arrow.down").imageScale(.small)
        }
        .labelsHidden()
        .help("Sort recipes based on an ordering")
        .foregroundColor(.theme)
        .pickerStyle(.automatic)
    }
}
