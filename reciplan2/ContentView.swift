import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(NavigationPathStore.self) private var navigationStore

    var body: some View {
        NavigationSplitView {
            TabView {
                // TODO:
                ///  1. Setup timeline model container ...
                ///  2. Setup the cloudkit integration and test multi-device syncing
                ///  3. Setup cloudkit sharing integration of recipes and/or timeline, test it out across two apple accounts
                ///  4. Recipe custom predicate for @Query - like the RecipeSearchableView (_must have_)
                ///  5. Investigate how Apple watch and SwiftData modelcontainer sync works, need to compress images before syncing somehow
//                TimelineView()
//                    .font(.title)
//                    .tabItem {
//                        Label("Timeline", systemImage: "calendar").accessibility(label: Text("Timeline"))
//                    }
//                    //.badge(timelineStore.numberOfPlannedRecipes())
//                    .tag(ContentViewSelection.View.timeline)
//                    .interactionActivityTrackingTag("Timeline")
                RecipeListView(navigation: navigationStore.recipe)
                    // .onOpenURL { navigationStore.handle($0) } // FIXME: Handle URLs, requires SwiftUI life-cycle
                    .font(.title)
                    .tabItem {
                        Label("Recipes", systemImage: "book.closed.fill").accessibility(label: Text("Recipes"))
                    }
                    .tag(ContentViewSelection.View.recipe)
                    .interactionActivityTrackingTag("Recipes")
//                SettingsView()
//                    .font(.title)
//                    .tabItem {
//                        Label("Settings", systemImage: "gear").accessibility(label: Text("Settings"))
//                    }
//                    .tag(ContentViewSelection.View.settings)
//                    .interactionActivityTrackingTag("Settings")
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
