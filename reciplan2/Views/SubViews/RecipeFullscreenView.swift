import SwiftUI

struct RecipeFullscreenView: View {
    @Environment(\.presentationMode) private var presentationMode
    // @Environment(\.reviewController) private var reviewController
    @State private var selection: Int = 0
    var recipe: Recipe
    @Binding var ingredients: Set<MeasuredIngredient>
    @Binding var instruction: String?
    @Binding var portions: Float
    @Binding var optionals: Bool
    @Binding var garnishes: Bool
    @Binding var order: IngredientOrder

    var body: some View {
        HStack {
            ScrollView(showsIndicators: false) {
                HStack {
                    Text("Ingredients").font(.headline)
                    Spacer()
                }

                IngredientListView(recipe: recipe, highlightedIngredients: $ingredients, portions: $portions, optionals: $optionals, garnishes: $garnishes, order: $order)
            }
            .padding([.top, .horizontal])
            
            ZStack {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Text("Instructions").font(.headline)
                        Spacer()
                    }
                    
                    InstructionListView(recipe: recipe, highlightedInstruction: $instruction)
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            // reviewController.lockOrientation(.portrait, andRotateTo: .portrait)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "x.circle.fill").buttonStyle(.bordered).foregroundColor(.theme)
                        }
                    }
                    Spacer()
                }
            }
            .padding([.top, .horizontal])
        }
        .interactionActivityTrackingTag("RecipeFullscreenView")
    }
}
