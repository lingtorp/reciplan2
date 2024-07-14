#if os(iOS)
import SwiftUI

// Ingredient order selection only used on regular horizontal size class (iPad)
struct OrderView: View {
    @Binding var order: IngredientOrder
    @Binding var optionals: Bool  // Toggle states
    @Binding var garnishes: Bool
    var body: some View {
        Menu {
            Section {
                Picker("Sort by", selection: $order) {
                    Label(IngredientOrder.alphabetical.localized,        systemImage: "abc").tag(IngredientOrder.alphabetical)
                    Label(IngredientOrder.inverseAlphabetical.localized, systemImage: "abc").tag(IngredientOrder.inverseAlphabetical)
                    Label(IngredientOrder.measurementSystem.localized,   systemImage: "arrow.3.trianglepath").tag(IngredientOrder.measurementSystem)
                    Label(IngredientOrder.original.localized,            systemImage: "arrow.3.trianglepath").tag(IngredientOrder.original)
                    Label(IngredientOrder.quantityLargest.localized,     systemImage: "number").tag(IngredientOrder.quantityLargest)
                    Label(IngredientOrder.quantitySmallest.localized,    systemImage: "number").tag(IngredientOrder.quantitySmallest)
                }
            }

            Toggle(isOn: $optionals) {
                Label("Show optional", systemImage: "questionmark.circle")
            }
            
            Toggle(isOn: $garnishes) {
                Label("Show garnishes", systemImage: "camera.macro.circle")
            }
        } label: {
            Label("\(order.localized)", systemImage: "arrow.up.arrow.down").font(.body)
        }
        .help("Ordering of ingredients")
        .foregroundColor(.red)
        .pickerStyle(.automatic)
    }
}
#endif
