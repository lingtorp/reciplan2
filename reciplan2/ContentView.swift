import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(NavigationPathStore.self) private var navigationStore

    var body: some View {
        NavigationSplitView {
            TabView {
                RecipeListView(navigation: navigationStore.recipe)
                    // .onOpenURL { navigationStore.handle($0) } // FIXME: Handle URLs, requires SwiftUI life-cycle
                    .font(.title)
                    .tabItem {
                        Label("Recipes", systemImage: "book.closed.fill").accessibility(label: Text("Recipes"))
                    }
                    .tag(ContentViewSelection.View.recipe)
                    .interactionActivityTrackingTag("Recipes")
            }
        } detail: {
            Text("Select a recipe")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self, inMemory: true)
        .environment(NavigationPathStore())
}
