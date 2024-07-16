import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var recipes: [Recipe]

    @Bindable var navigation: NavigationPathWrapper
    
    enum SubView: Hashable {
        // case recipeDetail(Recipe)
        case newRecipe
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            Group {
                if recipes.isEmpty {
                    NavigationLink(value: SubView.newRecipe) {
                        NoContentView(main: "No recipes added", secondary: "Tap to add a recipe")
                    }
                    .keyboardShortcut("n")
                } else {
                    // FIXME: Need tags model container for this
//                    RecipeSearchableListView(tags: recipeStore.uniqueTags, elements: recipeStore.recipes) { recipe in
//                        NavigationLink(value: SubView.recipeDetail(recipe)) {
//                            RecipeListCell(recipe: recipe)
//                        }
//                    }
                    List {
                        ForEach(recipes) { item in
                            NavigationLink {
                                RecipeDetail(recipe: item)
                            } label: {
                                VStack {
                                    RecipeListCell(recipe: item)
                                }
                             }
                         }
                         .onDelete(perform: deleteItems)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(value: SubView.newRecipe) {
                        Image(systemName: "plus").resizable().foregroundColor(.red).imageScale(.medium)
                    }
                    .keyboardShortcut("n")
                }
                ToolbarItem {
                    Button {
                        if let recipe = recipes.randomElement() {
                            // navigation.path.append(SubView.recipeDetail(recipe))
                            navigation.path.append(recipe)
                        }
                    } label: {
                        Image(systemName: "shuffle").resizable().foregroundColor(.red).imageScale(.medium)
                    }
                }
            }
            // FIXME: Use this instead of the since we get a BINDING and not a copy as with the current approach
            // .navigationDestination(item: Binding<Optional<Hashable>>) { destination in }
            .navigationDestination(for: SubView.self) { destination in
                switch destination {
                case .newRecipe:
                    NewRecipeView()
                // case .recipeDetail(let recipe):
                }
            }
            .navigationTitle(Text("📚 Recipes"))
        }
        .buttonStyle(.plain)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recipes[index])
            }
        }
    }
}
