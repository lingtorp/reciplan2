import Foundation
import SwiftData
import SwiftUI

@Model
final class Recipe {
    var favorite: Bool = false
    var name: String = ""      // Name of the recipe
    var headline: String = ""  // Description of the recipe, cannot be namned description due to overloaded naming
    var tags: [Tag] = []
    var imageURL: URL? = nil
    var ingredients: [MeasuredIngredient] = []
    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) 
    var instructions: [String] = []
    var cookingTimeMinutes: Int = 0 // Cooking time in minutes
    var prepTime: Int = 0           // Minutes
    var creationDate: Date = Date()
    var numberPortions: Int = 1
    var author: String = UserDefaults.standard.string(forKey: "defaultRecipeAuthor") ?? ""
    var languageCode: String = Locale.current.language.languageCode?.identifier ?? "en" // ISO 639-1 language code
    var calorieCount: Int = 0
    var rating: Int = 0 // in range [0, 5]
    init() {}
    
    
    // Is recipe non-empty and thus shareable?
    public var isValidForm: Bool {
        get {
            !name.isEmpty && !ingredients.isEmpty && !instructions.isEmpty
        }
    }
}
