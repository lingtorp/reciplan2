// Data models related to Recipes

import Foundation

// NOTE: Models here cant be integers or something that might change.
// For example changing the order of an enum will basically change the types in the databases
// Must have something that is more stable, such as a string or something

// MARK: - Ingredient order
enum IngredientOrder: Int, Identifiable, CaseIterable {
    case alphabetical        = 0
    case quantityLargest     = 1
    case quantitySmallest    = 2
    case measurementSystem   = 3
    case original            = 4
    case inverseAlphabetical = 5
    
    var id: Int {
        return self.rawValue
    }
    
    var localized: String {
        switch self {
        // TODO: Localize UI strings here
        case .alphabetical:        return NSLocalizedString("alphabetical", comment: "").capitalized
        case .inverseAlphabetical: return NSLocalizedString("inverse alphabetical", comment: "").capitalized
        case .quantityLargest:     return NSLocalizedString("largest quantity", comment: "").capitalized
        case .quantitySmallest:    return NSLocalizedString("smallest quantity", comment: "").capitalized
        case .measurementSystem:   return NSLocalizedString("per type", comment: "").capitalized
        case .original:            return NSLocalizedString("original", comment: "").capitalized
        }
    }
}

// MARK: - Filter
// Defines a sorting of recipes
enum Filter: Int, CaseIterable {
    case alphabetical         = 0
    case inverseAlphabetical  = 1
    case oldestFirst          = 2
    case newestFirst          = 3
    case highestRated         = 4
    case lowestRated          = 5
    
    var localized: String {
        // TODO: Localize UI strings here
        switch self {
        case .alphabetical: return "Alphabetical"
        case .inverseAlphabetical: return "Inverse alphabetical"
        case .oldestFirst:  return "Oldest first"
        case .newestFirst:  return "Newest first"
        case .highestRated: return "Highest rated"
        case .lowestRated:  return "Lowest rated"
        }
    }
}

// MARK: - MeasurementSystem
enum MeasurementSystem: Int, CaseIterable {
    case metric = 0, imperial = 1, us = 2, notApplicable = 3
}

extension MeasurementSystem {
    public static var fromLocale: MeasurementSystem {
            switch Locale.current.measurementSystem {
            case .metric:
                return .metric
            case .uk:
                return .imperial
            case .us:
                return .us
            default:
                return .metric
            }
    }
}

extension MeasurementSystem {
    // Returns the other systems (example: metric gives imperial and US)
    public var otherSystems: [MeasurementSystem] {
        get {
            switch self {
            case .metric:
                return [.imperial, .us]
            case .imperial:
                return [.us, .metric]
            case .us:
                return [.metric, .imperial]
            case .notApplicable:
                return []
            }
        }
    }
    
    // Localization key for the measurement system
    public var localizeKey: String {
        get {
            switch self {
            case .metric:
                return "metric"
            case .imperial:
                return "imperial"
            case .us:
                return "US"
            case .notApplicable:
                return ""
            }
        }
    }
}

// MARK: - DisplayedMeasurementSystem
// Used to determine how to display the recipe measurements in the UI
enum DisplayedMeasurementSystem: Int, CaseIterable {
    case metric = 0, imperial = 1, us = 2, original = 3
}

// MARK: - Ingredient
struct Ingredient: Codable, Hashable {
    var name: String
}

// MARK: - MeasurementType
enum MeasurementType: CaseIterable, Hashable { case volume, weight, misc }
extension MeasurementType: Identifiable, CustomStringConvertible {
    var id: String { String(describing: self) }
    
    // TODO: Localize and use ID instead of this?
    var description: String {
        switch self {
        case .volume:
            return "Volume"
        case .weight:
            return "Weight"
        case .misc:
            return "Misc."
        }
    }
}

/// MeasurementUnits with volume are in milliliters, weight in grams
enum MeasurementUnit: String, Codable, CaseIterable, Hashable {
    // Weight - metric
    case kilo, hecto, gram
    // Weight - american
    case USPound, USOunce
    // Weight - imperial
    case imperialPound, imperialOunce
    
    // Volume - metric
    case liter, deciliter, centiliter, milliliter
    // Volume - american
    case USFluidOunce, USCup, USPint, USGallon, USQuart
    // Volume - imperial
    case imperialFluidOunce, imperialCup, imperialPint, imperialQuart, imperialGallon
    // Volume - international versions
    case tablespoon, teaspoon, dessertspoon
    
    // Swedish special measurements
    case kryddmatt, teacup, coffeecup, kanna
    
    // Weird stuff that are used in recipes MeasurementSystem.none
    case piece, pinch, part, dash
}

// String conversions of MeasurementUnit
extension MeasurementUnit: Identifiable, CustomStringConvertible {
    // Returns the MeasurementUnit string equvivalent
    public func string(abbreviated abbr: Bool) -> String {
        // TODO: Should depends on the locale and settings of the user
        switch self {
        case .kilo:
            return abbr ? "kg" : "kilo"
        case .hecto:
            return abbr ? "hg" : "hecto"
        case .gram:
            return abbr ? "g" : "gram"
        case .liter:
            return abbr ? "l" : "liter"
        case .deciliter:
            return abbr ? "dl" : "deciliter"
        case .centiliter:
            return abbr ? "cl" : "centiliter"
        case .milliliter:
            return abbr ? "ml" : "milliliter"
        case .teaspoon:
            return abbr ? "tsp" : "teaspoon"
        case .dessertspoon:
            return abbr ? "dstspn" : "dessertspoon"
        case .tablespoon:
            return abbr ? "tbsp" : "tablespoon"
        case .USPound:
            return abbr ? "lb" : "US pounds"
        case .USOunce:
            return abbr ? "oz" : "US ounce"
        case .USFluidOunce:
            return abbr ? "fl. oz" : "US fl. oz"
        case .USCup:
            return abbr ? "cup" : "US cup"
        case .USPint:
            return abbr ? "pt" : "US pint"
        case .USQuart:
            return abbr ? "qt" : "US quart"
        case .USGallon:
            return abbr ? "gal" : "US gallon"
        case .imperialFluidOunce:
            return abbr ? "fl. oz" : "imp. fl. oz"
        case .imperialCup:
            return abbr ? "cp" : "imp. cup"
        case .imperialPint:
            return abbr ? "pt" : "imp. pint"
        case .imperialQuart:
            return abbr ? "qt" : "imp. quart"
        case .imperialGallon:
            return abbr ? "gal" : "imp. gallon"
        case .imperialOunce:
            return abbr ? "oz" : "imp. ounce"
        case .imperialPound:
            return abbr ? "lb" : "imp. pound"
        case .kryddmatt:
            return abbr ? "krm" : "kryddmått"
        case .teacup:
            return abbr ? "tekopp" : "tekopp"
        case .coffeecup:
            return abbr ? "kaffekopp" : "kaffekopp"
        case .kanna:
            return abbr ? "kanna" : "kanna"
        case .piece:
            return abbr ? "pc" : "piece"
        case .pinch:
            return abbr ? "pinch" : "pinch"
        case .part:
            return abbr ? "part" : "part"
        case .dash:
            return abbr ? "dash" : "dash"
        }
    }
    
    // Returns string of MeasurementUnit (automatically abbreviated if that setting is on)
    var description: String {
        return self.string(abbreviated: UserDefaults.standard.bool(forKey: "measurementAbbreviations"))
    }
    
    var id: String { String(describing: self) }
}

extension MeasurementUnit: Comparable {
    // Converts between units and returns the quantity expressed as the MeasurementUnit of 'to'
    // Example) convert(MeasurementUnit.kilos, 0.25, to: MeasurementUnit.USCups) -> (0.75, MeasurementUnit.USCups)
    public static func convert(from: MeasurementUnit, quantity: Float?, to: MeasurementUnit) -> Float? {
        guard let quantity = quantity else { return nil }
        if from.measurementType != to.measurementType {
            // logger.debug("[MeasurementUnit.convert()]: Tried to convert from incompatabile MeasurementUnits")
            return nil
        }
        if from == to { return quantity } // ml -> ml is the same
        return ((quantity * from.quantity) / to.quantity)
    }
    
    // Principal unit (volume - ml, weight - g, everything else itself)
    var principalUnit: MeasurementUnit {
        get {
            switch self.measurementType {
            case .volume:
                return MeasurementUnit.milliliter
            case .weight:
                return MeasurementUnit.gram
            case .misc:
                return self
            }
        }
    }
    
    // Volume is given in milliliters, weight in grams,
    var quantity: Float {
        get {
            switch self {
            // Volume - in milliliters
            case .liter:
                return 1000.0
            case .deciliter:
                return 100.0
            case .centiliter:
                return 10.0
            case .milliliter:
                return 1.0
            case .tablespoon:
                return 15.0
            case .kryddmatt:
                return 1.0
            case .teaspoon:
                return 5.0
            case .teacup:
                return 250.0
            case .kanna:
                return 2600.0
            case .USFluidOunce:
                return 29.57
            case .USCup:
                return 240.0
            case .USPint:
                return 473.176473
            case .USQuart:
                return 946.3529460
            case .USGallon:
                return 3785.41
            case .dessertspoon:
                return 10.0
            case .imperialFluidOunce:
                return 28.41
            case .imperialGallon:
                return 4546.09
            case .imperialQuart:
                return 1136.52
            case .imperialPint:
                return 568.26125
            case .imperialCup:
                return 250.0
            case .coffeecup:
                return 150.0
            // Weight - in grams
            case .kilo:
                return 1000.0
            case .hecto:
                return 100.0
            case .gram:
                return 1.0
            case .USPound, .imperialPound:
                return 453.592
            case .USOunce, .imperialOunce:
                return 28.3495
            case .pinch, .piece, .part, .dash:
                return 1.0
            }
        }
    }
    
    // Comparable protocol requirement
    static func <(lhs: MeasurementUnit, rhs: MeasurementUnit) -> Bool {
        return lhs.quantity < rhs.quantity
    }
    
    // Family members from other measurement systems including self or not
    public func familyMembersIn(system: MeasurementSystem, selfInclusive: Bool) -> [MeasurementUnit] {
        if selfInclusive {
            return familyMembers(in: system)
        } else {
            return familyMembers(in: system).filter { $0 != self }
        }
    }
    
    // Family members from other measurement systems
    public func familyMembers(in system: MeasurementSystem) -> [MeasurementUnit] {
        switch system {
        case .imperial:
            switch self.measurementType {
            case .volume:
                return [.imperialCup, .imperialPint, .imperialGallon, .imperialQuart, .dessertspoon, .imperialFluidOunce]
            case .weight:
                return [.imperialOunce, .imperialPound]
            case .misc:
                return [self]
            }
        case .metric:
            switch self.measurementType {
            case .volume:
                return [.liter, .milliliter, .deciliter, .centiliter, .tablespoon, .teaspoon, .dessertspoon]
            case .weight:
                return [.kilo, .hecto, .gram]
            case .misc:
                return [self]
            }
        case .us:
            switch self.measurementType {
            case .volume:
                return [.USCup, .teaspoon, .tablespoon, .USQuart, .USGallon, .USFluidOunce, .dessertspoon]
            case .weight:
                return [.USOunce, .USPound]
            case .misc:
                return [self]
            }
        case .notApplicable:
            return [self]
        }
    }

    // Returns all measurements in the same system and of the same type (example: metric and volume for .dl)
    var familyMembers: [MeasurementUnit] {
        get {
            switch self.measurementSystem {
            case .imperial:
                switch self.measurementType {
                case .volume:
                    return [.imperialCup, .imperialPint, .imperialGallon, .imperialPint, .imperialQuart, .dessertspoon, .imperialFluidOunce]
                case .weight:
                    return [.imperialOunce, .imperialPound]
                case .misc:
                    return [self]
                }
            case .metric:
                switch self.measurementType {
                case .volume:
                    return [.liter, .milliliter, .deciliter, .centiliter, .tablespoon, .teaspoon, .dessertspoon]
                case .weight:
                    return [.kilo, .hecto, .gram]
                case .misc:
                    return [self]
                }
            case .us:
                switch self.measurementType {
                case .volume:
                    return [.USCup, .teaspoon, .tablespoon, .dessertspoon, .USQuart, .USGallon, .USFluidOunce]
                case .weight:
                    return [.USOunce, .USPound]
                case .misc:
                    return [self]
                }
            case .notApplicable:
                return [self]
            }
        }
    }
    
    // Measurement type (volume, weight, misc)
    var measurementType: MeasurementType {
        get {
            switch self {
            case .kilo, .hecto, .gram, .USOunce, .imperialOunce, .imperialPound, .USPound:
                return MeasurementType.weight
            case .liter, .milliliter, .deciliter, .centiliter, .USGallon, .imperialGallon, .USCup, .imperialCup, .kryddmatt,
                 .USQuart, .imperialQuart, .USPint, .imperialPint, .teacup, .coffeecup, .kanna,
                 .tablespoon, .dessertspoon, .teaspoon, .imperialFluidOunce, .USFluidOunce:
                return MeasurementType.volume
            case .pinch, .piece, .part, .dash:
                return MeasurementType.misc
            }
        }
    }
        
    // Measurement system (US, metric, imperial)
    var measurementSystem: MeasurementSystem {
        get {
            switch self {
            case .kilo, .hecto, .gram, .liter, .deciliter, .milliliter, .centiliter, .kryddmatt, .coffeecup, .kanna, .teacup:
                return .metric
            case .USCup, .USPint, .USPound, .USQuart, .USGallon, .USOunce, .USFluidOunce:
                return .us
            case .imperialPint, .imperialCup, .imperialQuart, .imperialPound, .imperialOunce, .imperialGallon, .imperialFluidOunce:
                return .imperial
            case .pinch, .piece, .part, .dash:
                return .notApplicable
            case .tablespoon, .teaspoon, .dessertspoon:
                return MeasurementSystem(rawValue: UserDefaults.standard.integer(forKey: "measurementSystem"))!
            }
        }
    }
}

extension MeasurementUnit {
    // Returns the MeasurementType in a sorted order
    public static func sortedFiltered(type: MeasurementType, system: Int) -> [MeasurementUnit] {
        return MeasurementUnit.allCases.filter { fu -> Bool in
            return fu.measurementType == type
        }.filter { fu -> Bool in
            return fu.measurementSystem.rawValue == system
        }.sorted { (lhs, rhs) -> Bool in
            return lhs.quantity < rhs.quantity
        }
    }
}

// Nutritional values for a measured ingredient
// Ex) 500g cauliflower
struct NutritionalValues : Codable {
    var kcal: Int = 0
    var protein: Int = 0
    var fat: Int = 0
    var carbs: Int = 0  // = sugar + other carbs
    var sugars: Int = 0 // Inclusive with carbs
}

final class MeasuredIngredient: Identifiable, ObservableObject {
    let id = UUID()
    var ingredient: Ingredient = Ingredient(name: "")
    var measurement: Measurement = Measurement(quantity: 0.0, unit: .USCup)
    var nutritionalValues: NutritionalValues = NutritionalValues()
    var optional: Bool = false
    var garnish: Bool = false
    
    required init() { /* Required to have Codable in extension */ }
    
    init(_ ingredient: Ingredient, _ measurement: Measurement, _ optional: Bool = false, _ garnish: Bool = false) {
        self.ingredient = ingredient
        self.measurement = measurement
        self.optional = optional
        self.garnish = garnish
        self.nutritionalValues = NutritionalValues()
    }
}

extension MeasuredIngredient: Codable {
    // NOTE: Exclude ID from JSON encoding/decoding
    private enum CodingKeys: String, CodingKey {
        case ingredient, measurement, nutritionalValues, optional, garnish
    }
    
    convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ingredient = try values.decode(Ingredient.self, forKey: .ingredient)
        measurement = try values.decode(Measurement.self, forKey: .measurement)
        nutritionalValues = try values.decodeIfPresent(NutritionalValues.self, forKey: .nutritionalValues) ?? NutritionalValues()
        optional = try values.decodeIfPresent(Bool.self, forKey: .optional) ?? false
        garnish = try values.decodeIfPresent(Bool.self, forKey: .garnish) ?? false
    }
}

// NOTE: Custom hashable due to ingredient name and type (system) are the defining traits of this model
extension MeasuredIngredient: Hashable {
    static func ==(lhs: MeasuredIngredient, rhs: MeasuredIngredient) -> Bool {
        return lhs.ingredient.name.lowercased() == rhs.ingredient.name.lowercased()
        && lhs.measurement.unit.measurementType == rhs.measurement.unit.measurementType
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ingredient.name.lowercased())
        hasher.combine(measurement.unit.measurementType)
    }
}
