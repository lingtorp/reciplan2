import SwiftData
import SwiftUI

struct NewRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var recipe: Recipe = Recipe()
    
    var body: some View {
        RecipeEditView(recipe: recipe).interactionActivityTrackingTag("NewRecipeView")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        modelContext.insert(recipe)
                    } label: {
                        Text("Add").foregroundColor(.theme).font(.body)
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
    }
}

struct RecipeEditView: View {
    @Bindable var recipe: Recipe
    
    private enum SubView: Hashable {
        case editDescription
        case addIngredient
//        case editIngredient(MeasuredIngredient)
        case addInstruction
//        case addTag
//        case editTag(Tag)
    }
    
    private var ingredientSectionHeader: some View {
        HStack {
            Text("Ingredients").font(.headline)
            Spacer()
            NavigationLink(value: SubView.addIngredient) {
                Image(systemName: "plus").foregroundColor(.theme)
            }
        }
    }
    
    private var ingredientSection: some View {
        Section(header: ingredientSectionHeader) {
            List {
                ForEach(recipe.ingredients) { ingredient in
                    NavigationLink {
                        EditIngredientView(measured: ingredient)
                    } label: {
                        HStack {
                            Text(ingredient.name).font(.body)
                            Spacer()
                            if let quantity = ingredient.measurement.quantity {
                                if let str = Measurement.numberFormatter.string(from: quantity as NSNumber) {
                                    Divider().padding(.vertical)
                                    Text(str).font(.body)
                                    Text("\(ingredient.measurement.unit.description)").font(.body)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteRecipeIngredient)
                .onMove(perform: moveRecipeIngredient)
            }
        }
        .headerProminence(.increased)
    }
    
    private var instructionSectionHeader: some View {
        HStack {
            Text("Instructions").font(.headline)
            Spacer()
            NavigationLink(value: SubView.addInstruction) {
                Image(systemName: "plus").foregroundColor(.theme)
            }
        }
    }
    
    private var instructionSection: some View {
        Section(header: instructionSectionHeader) {
            List {
                ForEach($recipe.instructions, id: \.self) { instruction in
                    NavigationLink {
                        EditInstructionView(instruction: instruction)
                    } label: {
                        Text(instruction.wrappedValue).font(.body)
                    }
                }
                .onDelete(perform: deleteRecipeInstruction)
                .onMove(perform: moveRecipeInstruction)
            }
        }
        .headerProminence(.increased)
    }
    
    private var tagSectionHeader: some View {
        HStack {
            Text("Tags").font(.headline)
            Spacer()
//            NavigationLink(value: SubView.addTag) {
//                Image(systemName: "plus").foregroundColor(.theme)
//            }
            // FIXME: add tag views
        }
    }
    
//    private var tagSection: some View {
//        Section(header: tagSectionHeader) {
//            List {
//                // Tag selection
//                if !recipeStore.uniqueTags.isEmpty {
//                    ScrollView(.horizontal, showsIndicators: true) {
//                        HStack {
//                            // Clear button
//                            Button(role: .destructive) {
//                                withAnimation { recipe.tags.removeAll() }
//                            } label: {
//                                if !recipe.tags.isEmpty {
//                                    Image(systemName: "xmark.circle.fill").foregroundColor(.red).imageScale(.medium)
//                                } else {
//                                    Image(systemName: "xmark.circle").foregroundColor(.gray).imageScale(.medium)
//                                }
//                            }.padding(.trailing)
//                            
//                            ForEach(recipeStore.uniqueTags) { tag in
//                                if !recipe.tags.contains(tag) {
//                                    RecipeTagView(tag: tag, selected: false).onTapGesture {
//                                        // NOTE: Copying here to generate a new ID for the UI to keep track of
//                                        withAnimation {
//                                            guard !recipe.tags.contains(tag) else { return }
//                                            recipe.tags.append(Tag(name: tag.name, color: tag.color))
//                                            recipe.tags.sort { lhs, rhs in
//                                                lhs.name < rhs.name
//                                            }
//                                        }
//                                    }
//                                }
//                            }.frame(minHeight: 50)
//                        }.frame(minHeight: 55)
//                    }
//                    
//                    ForEach(recipe.tags) { tag in
//                        NavigationLink(value: SubView.editTag(tag)) {
//                            RecipeTagView(tag: tag, selected: false)
//                        }
//                    }.onDelete(perform: deleteRecipeTag).onMove(perform: moveRecipeTag)
//                }
//            }
//        }
//        .headerProminence(.increased)
//    }
    
    @State private var languageSearchQuery: String = ""
    private var filteredLanguageCodes: [Locale.LanguageCode] {
        Locale.LanguageCode.isoLanguageCodes.compactMap {
            if let str = Locale.current.localizedString(forLanguageCode: $0.identifier) {
                if languageSearchQuery.isEmpty {
                    return $0
                } else if search(needle: languageSearchQuery.lowercased(), haystack: str.lowercased()) {
                    return $0
                }
            }
            return nil
        }
    }
    
    private var extraSection: some View {
        Section(header: Text("Properties").font(.headline)) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Author").font(.headline)
                TextField(UserDefaults.standard.string(forKey: "defaultRecipeAuthor") ?? "", text: $recipe.author).font(.body)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Preparation time").font(.headline)
                    Spacer()
                    Text("minutes").foregroundColor(.gray).font(.body)
                }
                TextField("123", value: $recipe.prepTime, format: .number).keyboardType(.decimalPad).font(.body)
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Cooking time").font(.headline)
                    Spacer()
                    Text("minutes").foregroundColor(.gray).font(.body)
                }
                TextField("123", value: $recipe.cookingTimeMinutes, format: .number).keyboardType(.decimalPad).font(.body)
            }
            
            Stepper("\(recipe.numberPortions) portions", value: $recipe.numberPortions, in: 1...100).font(.headline)
            
            // TODO: Make this optioanl and compute the calorie count from ingredients if not filled in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Calories").font(.headline)
                    Spacer()
                    Text("kCal").foregroundColor(.gray).font(.body)
                }
                TextField("123", value: $recipe.calorieCount, format: .number).keyboardType(.decimalPad).font(.body)
            }
            
            Picker("Language", selection: $recipe.languageCode) {
                ForEach(filteredLanguageCodes, id: \.self) { code in
                    if let str = Locale.current.localizedString(forLanguageCode: code.identifier) {
                        Text(str).tag(code.identifier)
                    }
                }
            }.font(.headline)
            
            VStack {
                HStack {
                    Text("Rating").font(.headline)
                    Spacer()
                    RatingView(recipe: recipe, interactable: true).font(.body)
                }
            }
        }
        .headerProminence(.increased)
    }
    
    var body: some View {
        Form {
            RecipeImageView(recipe: recipe)
            
            Group {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Name").font(.headline)
                        Spacer()
                    }
                    TextField("...", text: $recipe.name).font(.body)
                }
            }
            
            NavigationLink(value: SubView.editDescription) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Description").font(.headline)
                        Spacer()
                    }
                    Text(recipe.headline).lineLimit(2).font(.subheadline).foregroundColor(.gray)
                }
            }
            
            // Ingredients
            ingredientSection
            
            // Instructions
            instructionSection
            
            // Tags
            // tagSection
            
            // Extra stuff
            extraSection
        }
        .interactionActivityTrackingTag("RecipeEditView")
        .navigationTitle(Text(recipe.name))
        .navigationDestination(for: SubView.self) { destination in
            switch destination {
            case .editDescription:
                DescriptionView(description: $recipe.headline)
            case .addInstruction:
                InstructionView(instructions: $recipe.instructions)
            case .addIngredient:
                IngredientView(recipe: recipe)
//            case .addTag:
//                NewTagView(tags: $recipe.tags)
            }
        }
    }
    
    // Mark: - View Utilities
    private func binding(for tag: Tag) -> Binding<Tag> {
        guard let index = recipe.tags.firstIndex(of: tag) else {
            fatalError("Tag not found in the recipe")
        }
        return $recipe.tags[index]
    }
    
    private func deleteRecipeIngredient(at offsets: IndexSet) {
        withAnimation { recipe.ingredients.remove(atOffsets: offsets) }
    }
    
    private func deleteRecipeInstruction(at offsets: IndexSet) {
        withAnimation { recipe.instructions.remove(atOffsets: offsets) }
    }
    
    private func deleteRecipeTag(at offsets: IndexSet) {
        withAnimation { recipe.tags.remove(atOffsets: offsets) }
    }
    
    private func moveRecipeInstruction(from: IndexSet, to: Int) {
        recipe.instructions.move(fromOffsets: from, toOffset: to)
    }
    
    private func moveRecipeIngredient(from: IndexSet, to: Int) {
        recipe.ingredients.move(fromOffsets: from, toOffset: to)
    }
    
    private func moveRecipeTag(from: IndexSet, to: Int) {
        recipe.tags.move(fromOffsets: from, toOffset: to)
    }
}
