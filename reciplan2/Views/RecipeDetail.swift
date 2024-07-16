import SwiftUI
// import ToastUI
// import AlertToast

struct RecipeDetail: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    // @Environment(\.reviewController) private var reviewController
    @State private var selection: Int = 0
    var recipe: Recipe
    @State private var ingredients: Set<MeasuredIngredient> = []
    @State private var instruction: String? = nil // nil == all
    
    @State private var showDuplicatedRecipeToast: Bool = false
    
    // Manual ingredient order selection
    @AppStorage("ingredientOrder") private var order: IngredientOrder = .original
    @AppStorage("showOptionals") private var optionals: Bool = true
    @AppStorage("showGarnishes") private var garnishes: Bool = true
    @State private var portions: Float = 1
    
    private enum SubView: Hashable {
        case editRecipe(Recipe)
    }
    
    private var swipe: some Gesture {
        DragGesture(minimumDistance: 10.0, coordinateSpace: .local)
                    .onEnded({ value in
                        let sensitivity = CGFloat(10.0) // Drag sensitivity
                        if value.translation.width > -sensitivity {
                            withAnimation { selection = 0 } // left
                        }
                        if value.translation.width < sensitivity {
                            withAnimation { selection = 1 } // right
                        }
                    })
    }
    
//    private var ipadView: some View {
//        Group {
//            TagsView(recipe: recipe).padding(.horizontal)
//
//            HStack {
//                ScrollView(showsIndicators: true) {
//                    IngredientListView(recipe: recipe, highlightedIngredients: $ingredients, portions: $portions,
//                                       optionals: $optionals, garnishes: $garnishes, order: $order)
//                        .padding(.horizontal)
//                }
//                
//                GroupBox {
//                    VStack {
//                        RecipeImageView(recipe: recipe).frame(maxHeight: 330)
//                        
//                        RatingView(recipe: recipe, interactable: true).padding(.bottom)
//                                                    
//                        HStack {
//                            Text("Portions \(recipe.numberPortions)") // FIXME: Servings vs. portions
//                            if recipe.cookingTimeMinutes > 0 {
//                                Spacer()
//                                Text("\(recipe.cookingTimeMinutes) " + cookingTimeFormatter().string(from: UnitDuration.minutes))
//                            }
//                            if recipe.calorieCount > 0 {
//                                Spacer()
//                                Text("\(recipe.calorieCount) kCal")
//                            }
//                            Spacer()
//                            Text(recipe.creationDate.string(dateStyle: .medium)).lineLimit(1)
//                        }.font(.body).foregroundColor(.secondary).padding(.bottom)
//                                                    
//                        Text(recipe.description).font(.body)
//                        
//                        Spacer()
//                                                
//                        HStack {
//                            Spacer()
//                            Text("Author: \(recipe.author)").font(.footnote).foregroundColor(.secondary)
//                            Spacer()
//                        }
//                    }
//                }.padding(.vertical)
//                                       
//                ScrollView(showsIndicators: true) {
//                    VStack {
//                        InstructionListView(recipe: recipe, highlightedInstruction: $instruction).padding(.horizontal)
//                    }
//                }
//            }
//        }
//    }
    
    // iPhone portrait view
    private var portraitView: some View {
        ScrollView {
            VStack {
                TagsView(recipe: recipe).padding(.horizontal)

                RecipeImageView(recipe: recipe).padding(.horizontal)
                
                Picker(selection: $selection, label: Text("Pick Ingredients or Instructions")) {
                    Text("Ingredients").tag(0)
                    Text("Instructions").tag(1)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .padding(.horizontal)
                   
                Group {
                    if selection == 0 {
                        IngredientListView(recipe: recipe, highlightedIngredients: $ingredients, portions: $portions, optionals: $optionals, garnishes: $garnishes, order: $order)
                    } else {
                        InstructionListView(recipe: recipe, highlightedInstruction: $instruction)
                    }
                }
                .highPriorityGesture(swipe)
                .padding()
            }
        }
    }
    
    @State private var showRecipeEditSheet = false
    @State private var isFullscreenPresented = false
    // @EnvironmentObject private var timer: RecipeTimer
    var body: some View {
        VStack {
            // FIXME: horizontalSizeClass
            // if horizontalSizeClass == .compact {
                portraitView
            // } else {
                // ipadView
            //}
        }
        .sheet(isPresented: self.$showRecipeEditSheet) {
            NavigationView {
                // RecipeEditView(recipe: recipe)
            }
        }
        .fullScreenCover(isPresented: $isFullscreenPresented,
                         content: {
            // RecipeFullscreenView(recipe: recipe, ingredients: $ingredients, instruction: $instruction,
                                 // portions: $portions, optionals: $optionals, garnishes: $garnishes, order: $order)
        })
        .interactionActivityTrackingTag("RecipeDetailView")
        .navigationTitle(recipe.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                 if horizontalSizeClass == .compact {
                    NavigationLink(value: SubView.editRecipe(recipe)) {
                        Text("Edit")
                    }.foregroundColor(.theme).font(.body)
                } else {
                    // FIXME: How does this look on iPad?? - should use Nav. Link as well??
                    Button {
                        showRecipeEditSheet.toggle()
                    } label: {
                        Text("Edit")
                    }.foregroundColor(.theme).font(.body)
                }
            }
            ToolbarTitleMenu {
                Button {
                    // reviewController.lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)
                    isFullscreenPresented.toggle()
                } label: {
                    Label("Fullscreen", systemImage: "arrow.up.left.and.arrow.down.right").font(.body).foregroundColor(.theme)
                }
                OrderView(order: $order, optionals: $optionals, garnishes: $garnishes)
                Menu("Portions \(portions, specifier: "%.1f")") {
                    Button("1 / 8") { portions = 1 / 4 }.tag(0)
                    Button("1 / 4") { portions = 1 / 4 }.tag(1)
                    Button("1 / 2") { portions = 1 / 2 }.tag(2)
                    Button("1 / 3") { portions = 1 / 3 }.tag(3)
                    ForEach(1..<21) { i in
                        Button("\(i)") { portions = Float(i) }.tag(i + 3)
                    }
                }
                Button {
                    // let copy = recipe
                    // copy.id = UUID().uuidString
                    // recipeStore.save(copy)
                    // FIXME: FIXME FIXME FIXME
                    showDuplicatedRecipeToast = true
                } label: {
                    Label("Duplicate", systemImage: "doc.on.doc")
                }
            }
        }
        .navigationDestination(for: SubView.self) { destination in
            switch destination {
            case .editRecipe(let recipe):
                RecipeEditView(recipe: recipe)
            }
        }
//        .toast(isPresented: $showDuplicatedRecipeToast, dismissAfter: 1.5) {
//            ToastView("Duplicated \(recipe.name)").toastViewStyle(SuccessToastViewStyle()).onTapGesture {
//                self.showDuplicatedRecipeToast = false
//            }
//        }
      }
}
