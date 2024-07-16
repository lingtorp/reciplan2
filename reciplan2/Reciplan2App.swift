import SwiftUI
import SwiftData

@main
struct reciplan2App: App {
    @State private var navigationPathStore = NavigationPathStore()

    var sharedModelContainer: ModelContainer = {
        // Register value transformers
        ColorValueTransformer.register()
        let name = NSValueTransformerName(rawValue: String(describing: NSSecureUnarchiveFromDataTransformer.self))
        ValueTransformer.setValueTransformer(NSSecureUnarchiveFromDataTransformer(), forName: name)
        
        let schema = Schema([
            Recipe.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContainer.mainContext.autosaveEnabled = false
            // Editing a recipe - changes are NOT reflect to the recipe listview with autosave TRUE
            // Editing a recipe - changes are reflect to the recipe listview with autosave FALSE
            return modelContainer
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environment(navigationPathStore)
    }
}
