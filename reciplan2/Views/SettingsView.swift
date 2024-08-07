import SwiftUI
import StoreKit
import MessageUI
//import ToastUI
import UserNotifications
import UniformTypeIdentifiers

struct AboutView: View {
    var body: some View {
        GroupBox {
            if let data = UIImage(named: "profilepicture")?.heicData() {
                CircleRecipeImageView(data: data)
            }

            Text("Hi,").font(.title).padding(.bottom)
            Text("I am Alexander (🇸🇪), the developer of Reciplan. Please consider supporting the development of Reciplan with a subscription.").allowsTightening(true).minimumScaleFactor(0.5)
            Spacer()
            
            HStack {
                Spacer()
                Link(destination: URL(string: "https://twitter.com/ALingtorp")!) {
                    Text("Twitter").foregroundColor(.theme)
                }
                Spacer()
                Link(destination: URL(string: "https://lingtorp.com")!) {
                    Text("Website").foregroundColor(.theme)
                }
                Spacer()
            }
            
            Spacer()
        }
        .padding()
        .font(.body)
        .navigationTitle("About")
    }
}

// FIXME: Export performance is very slow for 10+ recipes - move to database export
// For exporting and importing from JSON via system dialogs
struct RecipeDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.reciplan, .json] }
    
    private var recipes: [Recipe] = []
    
    init(recipes: [Recipe]) {
        self.recipes = recipes
    }

     init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        let decoder = JSONDecoder()
        // FIXME: self.recipes = try decoder.decode([Recipe].self, from: data)
     }

     func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
// FIXME:
//        let encoder = JSONEncoder()
//        let data = try encoder.encode(self.recipes)
//        return FileWrapper(regularFileWithContents: data)
         return FileWrapper()
     }
}

// MARK: - EXPORT VIEW
//struct ExportView: View {
//    @EnvironmentObject var recipeStore: RecipeStore
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//
//    // Presenting the file exporter
//    @State private var showFileExporter: Bool = false
//    @State private var selectedFilter: Filter = .alphabetical
//    @State private var selectedTags: Set<Tag> = Set<Tag>()
//    @State private var searchQuery: String = ""
//    @State private var searchbarFocused: Bool = false
//    @State private var selectedRecipes = Set<Recipe>()
//    
//    private var validForm: Bool {
//        get {
//            return !selectedRecipes.isEmpty
//        }
//    }
//            
//    var body: some View {
//        Group {
//            if recipeStore.recipes.isEmpty {
//                NoContentView(main: "No recipes to export", secondary: "Import or add recipes first")
//            } else {
//                let tags = recipeStore.uniqueTags
//                RecipeSearchableSelectableListView(tags: tags, recipes: $recipeStore.recipes, selection: $selectedRecipes) { recipe in
//                    RecipeListCell(recipe: recipe)
//                }
//            }
//        }
//        .environment(\.editMode, .constant(EditMode.active))
//        .toolbar {
//            ToolbarItem(placement: .confirmationAction) {
//                Button("Export (\(selectedRecipes.count))") {
//                    if validForm {
//                        showFileExporter = true
//                    }
//                }
//                .foregroundColor(validForm ? .theme : .gray)
//                .font(.body)
//                .keyboardShortcut(.defaultAction)
//            }
//        }
//        .navigationTitle("Export")
//        .navigationBarTitleDisplayMode(.large) // NOTE: Avoids the navbar getting too cramped (does not seem to work) :/
//        .fileExporter(
//            isPresented: $showFileExporter,
//            document: RecipeDocument(recipes: Array(selectedRecipes)),
//            contentType: .reciplan,
//            defaultFilename: "recipes-\(Date().string(dateStyle: .short))"
//        ) { _ in
//            showFileExporter = false
//            self.presentationMode.wrappedValue.dismiss()
//        }
//    }
//}

struct SettingsView: View {
    // MARK: - Settings state
    // Measurement system to convert recipe to for display
    // TODO: @appstorage("foo") all of these
    // FIXME: Need to set default for these UserDefaults values ... 
    @State private var measurementSystemSelection: Int = UserDefaults.standard.integer(forKey: "measurementSystem")
    @State private var notificationsOffsettedByPrepTime: Bool = UserDefaults.standard.bool(forKey: "notificationsOffsettedByPrepTime")
    @State private var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    @State private var notificationsDefaultTime: Date = UserDefaults.standard.object(forKey: "notificationsDefaultTime") as! Date
    @State private var measurementAbbreviations: Bool = UserDefaults.standard.bool(forKey: "measurementAbbreviations")
    @State private var ingredientOrderSelection: Int = UserDefaults.standard.integer(forKey: "ingredientOrder")
    @State private var keepScreenOn: Bool = UserDefaults.standard.bool(forKey: "keepScreenOn")
    @State private var temperatureSystem: Int = UserDefaults.standard.integer(forKey: "temperatureSystem")
    @State private var defaultRecipeAuthor: String = UserDefaults.standard.string(forKey: "defaultRecipeAuthor") ?? ""
    @State private var measurementRoundWholeUnits: Bool = UserDefaults.standard.bool(forKey: "measurementRoundWholeUnits")
    @State private var timelineWeekNumbers: Bool = UserDefaults.standard.bool(forKey: "timelineWeekNumbers") // Toggles between 'Nov. 8' / 'Week 48'
    
    @State private var showEraseAllDataAlert: Bool = false
    
    // Help popover modals
    @State private var showMeasurementRoundWholeUnitsHelp: Bool = false
    @State private var showNotificationsOffsetByPrepTimeHelp: Bool = false
    @State private var showMeasurementSystemHelp: Bool = false
    @State private var showNotificationsHelp: Bool = false
    
    // File import selection timeline & recipes
    @State private var isImportPresented = false
    
    // Import of recipes
    @State private var showRecipeImport = false // Selection view
    @State private var showFailedToImportFileToast: Bool = false
    @State private var importFileErrorMsg: String = ""
    
    // Import of timeline
    @State private var showTimelineImport = false // Selection view
    
    // Notification related toast
    @State private var showNotificationsDenied: Bool = false // Was denied notifications before redirect user to Settings.app
        
    #if DEBUG
    @State private var scheduledNotifications: [UNNotificationRequest] = []
    
    private func fetchAllScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                scheduledNotifications = requests
            }
        }
    }
    #endif
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingFeedbackMailView = false
    @State var isShowingIssueMailView = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("General")) {
                    NavigationLink(destination: DefaultAuthorView(defaultRecipeAuthor: $defaultRecipeAuthor)) {
                        Label("Default author", systemImage: "person")
                    }
                    
                    NavigationLink(destination: SubscriptionManagementView().environmentObject(SKStore())) {
                        Label("Subscription", systemImage: "dollarsign.circle")
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "person.crop.circle")
                    }
                    
                    Toggle(isOn: $keepScreenOn) {
                        Text("Keep screen on")
                    }
                }
                
                Section(header: Text("Measurements")) {
                    HStack {
                        Image(systemName: "questionmark.circle").foregroundColor(.theme).onTapGesture {
                            showMeasurementSystemHelp = true
                        }

                        Picker(selection: $measurementSystemSelection, label: Text("Measurement system")) {
                            ForEach(DisplayedMeasurementSystem.allCases) { system in
                                Text(verbatim: system.toString()).tag(system.rawValue)
                            }
                        }
                    }
                    .popover(isPresented: $showMeasurementSystemHelp) {
                        HelpPopover(title: "Measurement system selection") {
                            Text("Units from other measurement systems will be converted and displayed in this measurement system. \n\nOriginal will show the ingredients in the units in which they were added in.")
                        }
                        .interactionActivityTrackingTag("MeasurementSystemHelp")
                    }

                    Toggle(isOn: $measurementAbbreviations) {
                        Text("Abbreviations")
                    }
                }
                
                Section(header: Text("Notifications")) {
                    HStack {
                        Image(systemName: "questionmark.circle").foregroundColor(.theme).onTapGesture {
                            showNotificationsHelp = true
                        }
                        Toggle(isOn: $notificationsEnabled) {
                            Text("Enabled")
                        }
                    }
                    .popover(isPresented: $showNotificationsHelp) {
                        HelpPopover(title: "Notifications for planned recipes") {
                            Text("Posts a notificaiton at the set time for a planned recipe.")
                        }
                        .interactionActivityTrackingTag("NotificationsHelp")
                    }

                    if notificationsEnabled {
                        // Default notification time
                        DatePicker("Default time", selection: $notificationsDefaultTime, displayedComponents: .hourAndMinute)
                        
                        HStack {
                            Image(systemName: "questionmark.circle").foregroundColor(.theme).onTapGesture {
                                showNotificationsOffsetByPrepTimeHelp = true
                            }
                            Toggle(isOn: $notificationsOffsettedByPrepTime) {
                                Text("Offset by preparation time")
                            }
                        }
                        .popover(isPresented: $showNotificationsOffsetByPrepTimeHelp) {
                            HelpPopover(title: "Schedules notifications for planned recipes X minutes before set time where X is the preperation time") {
                                Text("Scheduling a notification on 19:00 on a recipe which has a preperation time of 45 minutes will show the notification at 18:15 if setting is turned on.")
                            }
                            .interactionActivityTrackingTag("NotificationsOffsetHelp")
                        }
                    }
                }

                Section(header: Text("Ingredients")) {
                    Picker(selection: $ingredientOrderSelection, label: Text("Display order")) {
                        ForEach(IngredientOrder.allCases) { order in
                            Text(verbatim: order.localized).tag(order.rawValue)
                        }
                    }
                }
                
                Section(header: Text("Timeline")) {
                    Button {
                        isImportPresented.toggle()
                    } label: {
                        // NOTE: HStack to make entire row clickable instead of only the text
                        HStack {
                            Label("Import timeline", systemImage: "square.and.arrow.down")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    
                    Toggle(isOn: $timelineWeekNumbers) {
                        Text("Week numbers")
                    }
                }
                
                // FIXME: Database size calculations is wrong and not updating when deleting the data ...
                // let str = ByteCountFormatter().string(fromByteCount: Int64(recipeStore.databaseSize + timelineStore.databaseSize))
                let str = "FIXME: Ask SwiftData for the storage used ..."
                Section(header: Text("Recipes"), footer: Text("Data used: \(str)")) {
//                    NavigationLink(destination: ExportView().imageScale(.medium)) {
//                        Label("Export recipes", systemImage: "square.and.arrow.up")
//                    }
                                  
                    Button {
                        isImportPresented.toggle()
                    } label: {
                        // NOTE: HStack to make entire row clickable instead of only the text
                        HStack {
                            Label("Import recipes", systemImage: "square.and.arrow.down")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    
//                    NavigationLink(destination: RecipeInternetImportView().imageScale(.medium)) {
//                        Label("Import recipe link", systemImage: "square.and.arrow.down")
//                    }

                    Button {
                        showEraseAllDataAlert.toggle()
                    } label: {
                        // NOTE: HStack to make entire row clickable instead of only the text
                        HStack {
                            Label("Delete all recipes", systemImage: "minus.circle").foregroundColor(.red)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .confirmationDialog("Are you sure you want to delete all data?", isPresented: $showEraseAllDataAlert) {
                        Button("Delete", role: .destructive, action: eraseAllData)
                    } message: {
                        Text("Deleting all will remove all saved recipes. \n Are you sure to delete?")
                    }
                    
                    Button {
                        // recipeStore.importSampleRecipes()
                    } label: {
                        Label("Re-add sample recipes", systemImage: "goforward.plus")
                    }
                    
                    Button {
                        Task {
                            // recipeStore.removeSampleRecipes()
                        }
                    } label: {
                        Label("Remove sample recipes", systemImage: "trash.slash")
                    }
                }
                                
                Section(header: Text("About")) {
                    Button {
                        isShowingFeedbackMailView = true
                    } label: {
                        Label("Feedback", systemImage: "envelope")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingFeedbackMailView) {
                        MailView(recipient: "feedback@reciplan.app", result: self.$result)
                    }
                    
                    Button {
                        isShowingIssueMailView = true
                        // FIXME: print(logger.export())
                    } label: {
                        Label("Report an issue", systemImage: "ladybug")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingIssueMailView) {
                        MailView(recipient: "issue@reciplan.app", result: self.$result)
                    }

                    // FIXME: Try to present the review controller after X number of starts
                    Button {
                        // FIXME: reviewController.present()
                    } label: {
                        Label("Leave a review", systemImage: "star.leadinghalf.filled")
                    }
                    Text("Version \(UIApplication.appVersion)")
                }
            }
            .font(.body)
            .navigationTitle("⚙️ Settings")
            .navigationViewStyle(.stack)
            .buttonStyle(.plain)
            .font(.body)
        }
        .onDisappear {
            UserDefaults.standard.setValue(measurementSystemSelection, forKey: "measurementSystem")
            UserDefaults.standard.setValue(notificationsEnabled, forKey: "notificationsEnabled")
            UserDefaults.standard.setValue(notificationsOffsettedByPrepTime, forKey: "notificationsOffsettedByPrepTime")
            UserDefaults.standard.setValue(notificationsDefaultTime, forKey: "notificationsDefaultTime")
            UserDefaults.standard.setValue(measurementAbbreviations, forKey: "measurementAbbreviations")
            UserDefaults.standard.setValue(ingredientOrderSelection, forKey: "ingredientOrder")
            UserDefaults.standard.setValue(keepScreenOn, forKey: "keepScreenOn")
            UserDefaults.standard.setValue(temperatureSystem, forKey: "temperatureSystem")
            UserDefaults.standard.setValue(measurementRoundWholeUnits, forKey: "measurementRoundWholeUnits")
            UserDefaults.standard.setValue(timelineWeekNumbers, forKey: "timelineWeekNumbers")
            UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        }
    }
    
    // Remove all data from databases
    private func eraseAllData() {
        print("FIXME: Delete all SwiftData data")
    }
}
