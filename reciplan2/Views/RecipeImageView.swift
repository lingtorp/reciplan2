import SwiftUI
import SwiftData

struct RecipeImageView: View {
    var recipe: Recipe
    @State private var showingAlert: Bool = false
    
    #if os(iOS)
    @State private var showImagePickerView: Bool = false
    @State private var isActivityPresented: Bool = false
    @State private var isActionSheetPresented: Bool = false

//    private var activityView: some View {
//        let item = RecipeActivityItemSource(recipe: recipe)
//        return ActivityView(isPresented: $isActivityPresented, items: [item])
//    }
    #endif
    
    @State private var counter = 0
    var body: some View {
        HStack {
            VStack {
                ZStack {
                    CircleRecipeImageView(data: recipe.image)
                        .frame(maxWidth: 350, maxHeight: 350).padding().scaledToFit()
                    
                    #if os(iOS)
                    VStack {
                        HStack(alignment: .top) {
                            Button {
                                let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
                                hapticFeedback.impactOccurred()
                                withAnimation {
                                    if !self.recipe.favorite {
                                        counter += 10
                                    }
                                    self.recipe.favorite = !self.recipe.favorite
                                }
                                
                            } label: {
                                Image(systemName: recipe.favorite ? "heart.fill" : "heart")
                                    .foregroundColor(.red).scaledToFit()
                            }
                            .padding().buttonStyle(.plain)
                            .confettiCannon(counter: $counter, num: 50, confettis: [.text("❤️")], openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
                            
                            Spacer()
                            
                            Button {
                                self.showingAlert = true
                            } label: {
                                Image(systemName: "trash").foregroundColor(.red).scaledToFit()
                            }
                            .confirmationDialog("Are you sure you want to remove \(recipe.name)?", isPresented: $showingAlert) {
                                Button("Remove", role: .destructive, action: removerecipe)
                            } message: {
                                Text("Remove \(recipe.name)?")
                            }
                            .padding().buttonStyle(.plain)
                        }
                    
                        Spacer()
                        
                        HStack(alignment: .bottom) {
                            Button {
                                self.showImagePickerView = true
                            } label: {
                                Image(systemName: "photo").foregroundColor(Color.theme)
                                .sheet(isPresented: self.$showImagePickerView) {
                                    ImagePickerView(sourceType: .photoLibrary) { image in
                                        self.recipe.image = image.heicData()
                                    }
                                }
                                .scaledToFit()
                                .padding().buttonStyle(.plain)
                            }
                            
                            Spacer()
                          
                            if recipe.isValidForm {
                                Button {
                                    isActionSheetPresented = !isActionSheetPresented
                                    // FIXME: FIXME
//                                    if recipe.uploadedURL == nil {
//                                        DispatchQueue.main.async {
//                                            let url = recipe.exportToFileURL(userInfo: [Recipe.includeImageCropped : true,
//                                                                                        Recipe.includeImageCroppedWidth : 512,
//                                                                                        Recipe.includeImageCroppedHeight : 512,
//                                                                                        Recipe.includeImageQuality : 0.75,
//                                                                                        Recipe.includeID : false])
//                                            recipe.uploadRecipe(file: url)
//                                        }
//                                    }
                                } label: {
                                    Image(systemName: "square.and.arrow.up").foregroundColor(Color.theme).scaledToFit()
                                }
                                .actionSheet(isPresented: $isActionSheetPresented, content: {
                                    var buttons: [ActionSheet.Button] = []
                                    
                                    // Only show link share if we have successfully uploaded
                                    buttons.append(ActionSheet.Button.default(Text("Share link"), action: {
                                        //recipe.shareType = .link
                                        // FIXME:
                                        isActivityPresented = true
                                    }))
                                    
                                    buttons.append(contentsOf: [
                                        ActionSheet.Button.default(Text("Share"), action: {
                                            //recipe.shareType = .full
                                            // FIXME:
                                            isActivityPresented = true
                                        }),
                                        ActionSheet.Button.cancel()
                                    ])
                                    
                                    return ActionSheet(title: Text("Share recipe"), message: Text(recipe.name), buttons: buttons)
                                })
                                //.background(activityView)
                                .padding().buttonStyle(.plain)
                            }
                        }
                    }
                    #endif
                }
            }
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    private func removerecipe() {
        modelContext.delete(recipe)
        self.presentationMode.wrappedValue.dismiss()
    }
}

