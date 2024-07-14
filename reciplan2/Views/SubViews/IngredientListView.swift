import SwiftUI

struct IngredientListView: View {
    var recipe: Recipe
    @Binding var highlightedIngredients: Set<UUID>
    @Binding var portions: Float
    @Binding var optionals: Bool
    @Binding var garnishes: Bool
    @Binding var order: IngredientOrder

    @AppStorage("measurementAbbreviations") private var measurementAbbreviations: Bool = true
    @AppStorage("measurementSystem") private var measurementSystemPref: MeasurementSystem = .metric
        
    // Menu for ingredient measurement in other measurement systems
    @ViewBuilder
    private func menuItemsFor(ingredient: MeasuredIngredient) -> some View {
        Group {
            #if os(iOS)
            // Ingredient sorting selector
            ForEach(MeasurementSystem.allCases) { system in
                Menu(system.localizeKey.capitalized) {
                    ForEach(ingredient.measurement.unit.familyMembersIn(system: system, selfInclusive: false).sorted()) { unit in
                        let quantity = (portions / Float(recipe.numberPortions)) * (ingredient.measurement.quantity ?? 0)
                        if let converted = MeasurementUnit.convert(from: ingredient.measurement.unit, quantity: quantity, to: unit) {
                            Button {
                                UIPasteboard.general.string = converted.formatted()
                            } label: {
                                Image(systemName: "doc.on.doc")
                                Text(converted.formatted() + " " + unit.string(abbreviated: measurementAbbreviations))
                            }
                        }
                    }
                }
            }
            #else
            // FIXME: Should this be implemented on Apple Watch?
            #endif
        }
    }
    
    @ViewBuilder
    private func innerAdaptiveIngredientRowView(ingredient: MeasuredIngredient) -> some View {
        let highlighted = highlightedIngredients.contains(ingredient.id)
        AdaptiveStack {
            Text(ingredient.ingredient.name).foregroundColor(highlighted ? .secondary : .primary)
            Spacer()
            if let quantity = ingredient.measurement.quantity {
                let converted = ingredient.measurement.normalized(in: measurementSystemPref,
                                                                  scale: Float(portions) / Float(recipe.numberPortions))
                if let str = Measurement.numberFormatter.string(from: quantity as NSNumber) {
                    Text(str + " " + converted.unit.string(abbreviated: measurementAbbreviations)).foregroundColor(.secondary)
                }
            }
        }
        .strikethrough(highlighted)
    }
    
    @ViewBuilder
    private func ingredientsList(for ingredients: [MeasuredIngredient]) -> some View {
        ForEach(ingredients) { ingredient in
            Button {
                if highlightedIngredients.contains(ingredient.id) {
                    highlightedIngredients.remove(ingredient.id)
                } else {
                    highlightedIngredients.insert(ingredient.id)
                }
            } label: {
                #if os(iOS)
                GroupBox {
                    innerAdaptiveIngredientRowView(ingredient: ingredient)
                }
                .contextMenu {
                    menuItemsFor(ingredient: ingredient)
                }
                #elseif os(watchOS)
                Group {
                    innerAdaptiveIngredientRowView(ingredient: ingredient)
                }
                #endif
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            let ingredients = recipe.ingredients.filter { !$0.optional && !$0.garnish }
            ingredientsList(for: ingredients)
            
            Group {
                let optionalIngredients = recipe.ingredients.filter { $0.optional && optionals }
                if !optionalIngredients.isEmpty {
                    #if os(watchOS)
                    ingredientsList(for: optionalIngredients)
                    #else
                    GroupBox {
                        DisclosureGroup {
                            ingredientsList(for: optionalIngredients)
                        } label: {
                            Label("Optional", systemImage: "questionmark.circle").foregroundColor(.theme)
                        }
                    }
                    #endif
                }

                let garnishIngredients = recipe.ingredients.filter { $0.garnish && garnishes }
                if !garnishIngredients.isEmpty {
                    #if os(watchOS)
                    ingredientsList(for: garnishIngredients)
                    #else
                    GroupBox {
                        DisclosureGroup {
                            ingredientsList(for: garnishIngredients)
                        } label: {
                            Label("Garnish", systemImage: "camera.macro.circle").foregroundColor(.theme)
                        }
                    }
                    #endif
                }
            }.padding(.top)
        }
        .onChange(of: order) { newValue in
            recipe.ingredients = recipe.ingredients.sorted(order: newValue)
        }
    }
}
