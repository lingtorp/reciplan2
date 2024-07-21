import Foundation
import SwiftUI
import EventKit
import Combine
import OSLog

// MARK: - Date
extension Date {
    /// Returns a Date today with the set hour and minute
    static func with(hour: Int, minute: Int) -> Date {
        return Calendar.autoupdatingCurrent.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
    }
    
    /// Returns a the Date self with the hour and minute set
    func with(hour: Int, minute: Int) -> Date {
        return Calendar.autoupdatingCurrent.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
    }
    
    /// Start of the week typically Monday/Sunday 23:00 PM
    var weekStart: Date {
        get {
            return Calendar.autoupdatingCurrent.dateInterval(of: .weekOfYear, for: self)!.start
        }
    }
    
    /// End of the week typically Monday/Sunday 23:00 PM
    var weekEnd: Date {
        get {
            return Calendar.autoupdatingCurrent.dateInterval(of: .weekOfYear, for: self)!.end
        }
    }
    
    /// Year, as in 2022 (YYYY)
    var year: Int {
        return Calendar.autoupdatingCurrent.component(.year, from: self)
    }
    
    /// Example: 2020-32 [YYYY-WW, year-week]
    var yearWeek: String {
        // FIXME: Using this as key into a db might be a bit brittle since if the user changes date/time it will break
        let components = Calendar.autoupdatingCurrent.dateComponents([.year, .weekOfYear], from: self)
        let year = components.year! // Just crash here if this fails ..
        let week = components.weekOfYear!
        return "\(year)-\(week)"
    }
    
    /// Week in the year in range [0, 51]
    var week: Int {
        return Calendar.autoupdatingCurrent.component(.weekOfYear, from: self)
    }
    
    /// Short weekday string according to user locale
    /// Example:  'Mon', 'Tue', etc
    var shortWeekdaySymbol: String {
        return Locale.autoupdatingCurrent.calendar.shortWeekdaySymbols[self.weekDay - 1]
    }
    
    /// Full weekday string according to user locale
    /// Example:  'Monday', 'Tuesday', etc
    var fullWeekdaySymbol: String {
        return Locale.autoupdatingCurrent.calendar.weekdaySymbols[self.weekDay - 1]
    }
    
    /// Identifier for the day unit.
    var day: Int {
        return Calendar.autoupdatingCurrent.component(.day, from: self)
    }
        
    // The weekday units are the numbers 1 through N (where for the Gregorian calendar N=7 and 1 is Sunday)
    var weekDay: Int {
        return Calendar.autoupdatingCurrent.component(.weekday, from: self)
    }
    
    // The weekday units are the numbers 1 through N (mon, tue, wed, thu, fri, ..) = (0, 1, 2, 3, ..)
    var weekDayIndex: Int { // dayInWeek
        return (Calendar.autoupdatingCurrent.component(.weekday, from: self) - 2) % 7
    }
    
    // Identifier for the month unit.
    var month: Int {
        return Calendar.autoupdatingCurrent.component(.month, from: self)
    }
    
    var monthString: String {
        return Calendar.autoupdatingCurrent.monthSymbols[self.month - 1]
    }
    
    var hour: Int {
        return Calendar.autoupdatingCurrent.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.autoupdatingCurrent.component(.minute, from: self)
    }
    
    /// SQL DATE string of format ISO8601
    /// Note: SQLite does not have an official date format but stores it as strings according to ISO8601
    var databaseDateValue: String {
        return ISO8601DateFormatter().string(from: self)
    }
    
    // Date to locale aware string in custom date style and no time component (?)
    public func string(dateStyle: DateFormatter.Style, relative: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.calendar = Calendar.autoupdatingCurrent
        dateFormatter.doesRelativeDateFormatting = relative
        dateFormatter.dateStyle = dateStyle
        return dateFormatter.string(from: self)
    }
    
    // Date string in custom format and no time component (?)
    public func string(format: String, relative: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.calendar = Calendar.autoupdatingCurrent
        dateFormatter.doesRelativeDateFormatting = relative
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    // MARK: - Date modification
    func advance(months: Int) -> Date {
        return Calendar.autoupdatingCurrent.date(byAdding: .month, value: months, to: self)!
    }
    
    func advance(weeks: Int) -> Date {
        return Calendar.autoupdatingCurrent.date(byAdding: .day, value: 7 * weeks, to: self)!
    }
    
    func advance(days: Int) -> Date {
        return Calendar.autoupdatingCurrent.date(byAdding: .day, value: days, to: self)!
    }
    
    func advance(hours: Int) -> Date {
        return Calendar.autoupdatingCurrent.date(byAdding: .hour, value: hours, to: self)!
    }
    
    func advance(minutes: Int) -> Date {
        return Calendar.autoupdatingCurrent.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func advance(seconds: Int) -> Date {
        return Calendar.autoupdatingCurrent.date(byAdding: .second, value: seconds, to: self)!
    }
}

// MARK: - UIImage
extension UIImage {
    // Crops the image and dumps it to to a temporary URL .jpg if success otherwise nil
//    public func exportToURL() -> URL? {
//        let path = FileManager.default.temporaryDirectory.appendingPathComponent("\(ProcessInfo.processInfo.globallyUniqueString).jpg")
//        let cropped = self.resize(withSize: CGSize(width: 512, height: 512), contentMode: .contentAspectFill)
//        do {
//            try cropped?.jpegData(compressionQuality: 0.5)?.write(to: path, options: .atomic)
//            return path
//        } catch let error {
//            logger.error("exportImageToURL() failed with error: \(error.localizedDescription)")
//            return nil
//        }
//    }
}

// MARK: - Array for [Recipe]
extension Array where Element == Recipe {
    // List of unique Tags in alphabetical order
    var uniqueTags: [Tag] {
        get {
            if self.isEmpty {
                return []
            }
            
            var tags: [Tag] = []
            for recipe in self {
                tags.append(contentsOf: recipe.tags)
            }
            
            return Array<Tag>(Set(tags)).sorted { lhs, rhs in
                lhs.name < rhs.name
            }
        }
    }
}

// MARK: - String
extension String {
    func image(background: UIColor = UIColor.white.withAlphaComponent(0.0)) -> UIImage {
        let fontSize = 50
        let size = CGSize(width: fontSize, height: fontSize)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        background.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 50.0)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension Array where Element == MeasuredIngredient {
    // Returns all ingredients sorted by the order
    func sorted(order: IngredientOrder) -> [MeasuredIngredient] {
        return self.sorted {
            switch order {
            case IngredientOrder.quantityLargest:
                return $0.measurement.normalizedQuantity > $1.measurement.normalizedQuantity
            case IngredientOrder.quantitySmallest:
                return $0.measurement.normalizedQuantity < $1.measurement.normalizedQuantity
            case IngredientOrder.measurementSystem:
                return $0.measurement.unit.measurementType.hashValue < $1.measurement.unit.measurementType.hashValue
            case IngredientOrder.alphabetical:
                return $0.name < $1.name
            case IngredientOrder.inverseAlphabetical:
                return $0.name > $1.name
            case IngredientOrder.original:
                return true
            }
        }
    }
}

extension Collection {
  public var powerSet: [[Element]] {
    guard let first = self.first else { return [[]] }
    return self.dropFirst().powerSet.flatMap{[$0, [first] + $0]}
  }
}

struct GroupedSearchResult<Element: Hashable & Identifiable>: Hashable, Identifiable {
    let id: UUID = UUID()
    let tags: Set<Tag>      // Tags that matched the search of 'recipes'
    var elements: [Element] // Elements of which tags are a subset of 'tags'
}

//extension Array where Element == Recipe {
//    // Returns all recipes matching the search query, filter and matching tags (empty = all)
//    func groupSorted(query: String, filter: Filter, tags: Set<Tag>, onlyFavorites: Bool) -> [GroupedSearchResult<Recipe>] {
//        if tags.isEmpty {
//            let group = GroupedSearchResult(tags: tags,
//                                            elements: self.sorted(query: query, filter: filter, onlyFavorites: onlyFavorites))
//            // For example an invalid text search will lead to this
//            if group.elements.isEmpty {
//                return []
//            }
//
//            return [group]
//        }
//
//        let queried = self.sorted(query: query, filter: filter, onlyFavorites: onlyFavorites)
//        if queried.isEmpty {
//            return []
//        }
//
//        var groups: [GroupedSearchResult<Element>] = []
//        // NOTE: Need to find all the unique permutations of tags a.k.a powerset
//        // Ex) ([Dinner], [Vegan], [Quick]) -> ([Dinner]), ([Vegan]), ([Quick]), ([Dinner], [Vegan]),
//        //     ([Dinner], [Quick]), ..., ([Dinner], [Vegan], [Quick])
//        for elements in tags.powerSet {
//            guard !elements.isEmpty else { continue }
//            let permutation = Set(elements)
//            let matches = queried.filter { recipe in
//                return permutation.isSubset(of: recipe.tags)
//            }
//            // Filter empty groups
//            guard !matches.isEmpty else { continue }
//            groups.append(GroupedSearchResult(tags: permutation, elements: matches))
//        }
//
//        // Filter recipes that match with more tags from the other groups
//        for (i, _) in groups.enumerated() {
//            groups[i].elements = groups[i].elements.filter { element in
//                for grp in groups {
//                    if grp.id == groups[i].id { continue }
//                    if grp.tags.count <= groups[i].tags.count { continue }
//                    if grp.elements.firstIndex(of: element) != nil {
//                        return false
//                    }
//                }
//                return true
//            }
//        }
//
//        // Remove empty groups after filtering
//        groups = groups.filter { group in
//            return !group.elements.isEmpty
//        }
//
//        // Groups with the most tags, most recipes first
//        groups.sort { lhs, rhs in
//            if (lhs.tags.count > rhs.tags.count) {
//                return true
//            }
//
//            if (lhs.tags.count == rhs.tags.count) {
//                if (lhs.elements.count > rhs.elements.count) {
//                    return true
//                }
//            }
//            return false
//        }
//        return groups
//    }
//
//    // Returns all recipes matching the search query, filter and matching tags (empty = all), filters out non-favorites
//    func sorted(query: String, filter: Filter, onlyFavorites: Bool) -> [Recipe] {
//        if onlyFavorites {
//            return sorted(query: query, filter: filter).filter { recipe in
//                recipe.favorite
//            }
//        } else {
//            return sorted(query: query, filter: filter)
//        }
//    }
//
//    // Returns all recipes matching the search query, filter and matching tags (empty = all)
//    func sorted(query: String, filter: Filter, tags: Set<Tag>) -> [Recipe] {
//        if tags.isEmpty {
//            return self.sorted(query: query, filter: filter)
//        }
//
//        return self.sorted(query: query, filter: filter).filter { element in
//            return tags.isSubset(of: element.tags)
//        }
//    }
//
//    // Returns all recipes matching the search query and filter
//    func sorted(query: String, filter: Filter) -> [Recipe] {
//        return self.sorted(filter: filter).filter { element -> Bool in
//            var found = query.count == 0 || search(needle: query.lowercased(), haystack: element.name.lowercased())
//
//            // Search among tags too
//            for tag in element.tags {
//                found = found || search(needle: query.lowercased(), haystack: tag.name)
//            }
//
//            return found
//        }
//    }
//
//    // Returns all recipes matching the filter
//    func sorted(filter: Filter) -> [Recipe] {
//        // TODO: Switch to sort to avoid expensive copy
//        return self.sorted(by: { lhs, rhs -> Bool in
//            switch filter {
//            case .newestFirst:
//                return lhs.creationDate > rhs.creationDate
//            case .oldestFirst:
//                return lhs.creationDate < rhs.creationDate
//            case .alphabetical:
//                return lhs.name < rhs.name
//            case .inverseAlphabetical:
//                return lhs.name > rhs.name
//            case .highestRated:
//                return lhs.rating > rhs.rating
//            case .lowestRated:
//                return lhs.rating < rhs.rating
//            }
//        })
//    }
//}

// MARK: - DisplayedMeasurementSystem
// FIXME: Localize
extension DisplayedMeasurementSystem {
    public func toString() -> String {
        switch self {
        case .metric:
            return String(localized: "Metric")
        case .imperial:
            return String(localized: "Imperial")
        case .us:
            return String(localized: "US")
        case .original:
            return String(localized: "Original")
        }
    }
}

extension DisplayedMeasurementSystem: Identifiable, CustomStringConvertible {
    var description: String { String(describing: self.rawValue) }
    var id: String { String(describing: self) }
}

extension MeasurementSystem {
    public func toString() -> String {
        switch self {
        case .metric:
            return "Metric"
        case .imperial:
            return "Imperial"
        case .us:
            return "US"
        case .notApplicable:
            return "N.A"
        }
    }
}

extension MeasurementSystem: Identifiable, CustomStringConvertible {
    var description: String { String(describing: self.rawValue) }
    var id: String { String(describing: self) }
}

// MARK: - SafariView
#if !os(watchOS)
import SafariServices
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}
#endif

// MARK: - UIColor
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            alpha:   Double(a) / 255
        )
    }
    
    convenience init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red:   Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue:  Double((hex >> 00) & 0xff) / 255,
            alpha: alpha
        )
    }
    
    // Converts the color into a hexadecimal string representation
    func toHexadecimal() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}


// MARK: - UIColor
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue:  Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    // Converts the color into a hexadecimal string representation
    func toHexadecimal() -> String {
        let components = UIColor(self).cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }

    public func opacity(_ alpha: Double) -> Color {
        let components = self.cgColor?.components
        let r: Double = Double(components?[0] ?? 0.0)
        let g: Double = Double(components?[1] ?? 0.0)
        let b: Double = Double(components?[2] ?? 0.0)
        return Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// Dark/light mode theming related
extension Color {
    static var error: Color  {
        return Color("error")
    }
    
    static var success: Color  {
        return Color("success")
    }
    
    static var warning: Color  {
        return Color("warning")
    }
    
    static var solidButtontext: Color  {
        return Color("solidButtontext")
    }
    
    static var textHeaderPrimary: Color  {
        return Color("textHeaderPrimary")
    }
    
    static var textHeaderSecondary: Color  {
        return Color("textHeaderSecondary")
    }
}
// MARK: - Stuff missing from UIKit
#if !os(watchOS)
import Foundation
import UIKit
import SwiftUI

// MARK: - UIApplication
extension UIApplication {
    // App version string from project file
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    // App build number string from project file
    static var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
}

extension Color {
    /// Color wrappers
    // UIColor.tertiaryLabel
    public static var tertiary: Color {
        return Color(UIColor.tertiaryLabel)
    }
    
    // UIColor.quaternaryLabel
    public static var quaternary: Color {
        return Color(UIColor.quaternaryLabel)
    }
    
    // UIColor.placeholderText
    public static var placeholder: Color {
        return Color(UIColor.placeholderText)
    }
    
    // UIColor.separator
    public static var separator: Color {
        return Color(UIColor.separator)
    }
}
#endif

// MARK: - FileManager
extension FileManager {
    public func fileSizeAt(filepath: String) -> UInt64 {
        do {
            let attributes = try self.attributesOfItem(atPath: filepath)
            if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                return fileSize
            }
        } catch let error {
            // logger.warning("[fileSizeAt()]: Failed to get file size, error: \(error.localizedDescription)")
        }
        return 0
    }
    
    public func fileSizeStringAt(filepath: String) -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSizeAt(filepath: filepath)), countStyle: .memory)
    }
}
    
// MARK: - NSData
extension NSData {
    public var kilobytes: Float {
        get { Float(self.length) / 1024.0 }
    }
    
    public var megabytes: Float {
        get { self.kilobytes / 1024.0 }
    }
    
    public var gigabytes: Float {
        get { self.megabytes / 1024.0 }
    }
}

// MARK: - EventKit related
extension EKEventStore {
    static func askPermission(type: EKEntityType, gotAccess: @escaping (EKEventStore) -> Void) {
        let store = EKEventStore()

        let status = EKEventStore.authorizationStatus(for: type)
        
        switch status {
        case .authorized:
            gotAccess(store)
        case .notDetermined:
            // NOTE: Called back on an arbitrary queue
            store.requestAccess(to: type) { (granted, error) in
                if let err = error {
                    print(err)
                }
                
                if granted {
                    gotAccess(store)
                }
            }
        default:
            break // nop
        }
    }
}

extension EKEntityType {
    public var mask: EKEntityMask {
        get {
            switch self {
            case EKEntityType.reminder:
                return EKEntityMask.reminder
            case EKEntityType.event:
                return EKEntityMask.event
            @unknown default:
                fatalError("Apple added more EKEntityType:s")
            }
        }
    }
}

// Add modifier that can toggle modifiers on SwiftUI views
extension Text {
    func active(
        _ active: Bool,
        _ modifier: (Text) -> () -> Text
    ) -> Text {
        guard active else { return self }
        return modifier(self)()
    }
}

// Selection of the TabView in the main content view - used for SwiftUI/external communication
final class ContentViewSelection: ObservableObject {
    enum View: Int {
        case timeline = 0, recipe = 1, settings = 2
    }
    
    @Published var selection: ContentViewSelection.View = .timeline
}

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
    formatter.unitsStyle = style
    return formatter.string(from: self) ?? ""
  }
}

// MARK: - Environment Keys

/// MeasurementFormatter
private struct CookingTimeFormatterKey: EnvironmentKey {
    static let defaultValue = MeasurementFormatter()
}

extension EnvironmentValues {
  var cookingTimeFormatter: MeasurementFormatter {
    get { self[CookingTimeFormatterKey.self] }
    set { self[CookingTimeFormatterKey.self] = newValue }
  }
}

/// RelativeDateTimeFormatterKey
private struct RelativeDateTimeFormatterKey: EnvironmentKey {
    static let defaultValue = DateFormatter()
}

extension EnvironmentValues {
    var relativeDateTimeFormatter: DateFormatter {
        get { self[RelativeDateTimeFormatterKey.self] }
        set { self[RelativeDateTimeFormatterKey.self] = newValue }
    }
}

/// NavigationPath
private struct NavigationPathKey: EnvironmentKey {
    static let defaultValue = NavigationPath()
}

extension EnvironmentValues {
  var navigationPath: NavigationPath {
    get { self[NavigationPathKey.self] }
    set { self[NavigationPathKey.self] = newValue }
  }
}

// Mark: - View
extension View {
    func iOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(iOS)
        return modifier(self)
        #else
        return self
        #endif
    }
}

extension View {
    func macOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(macOS)
        return modifier(self)
        #else
        return self
        #endif
    }
}

extension View {
    func tvOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(tvOS)
        return modifier(self)
        #else
        return self
        #endif
    }
}

extension View {
    func watchOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
#if os(watchOS)
        return modifier(self)
#else
        return self
#endif
    }
}

// MARK: - Logger
extension Logger {
    func export() -> [String] {
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let date = Date.now.addingTimeInterval(-24 * 3600)
            let position = store.position(date: date)
            return try store
                .getEntries(at: position)
                .compactMap { $0 as? OSLogEntryLog }
                .filter { $0.subsystem == Bundle.main.bundleIdentifier! }
                .map { "[\($0.date.formatted())] [\($0.category)] \($0.composedMessage)" }
        } catch {
            // logger.error("\(error.localizedDescription, privacy: .public)")
            return []
        }
    }
}

