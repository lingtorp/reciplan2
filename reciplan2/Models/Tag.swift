import SwiftUI
import SwiftData

// MARK: - Tag
@Model
final class Tag: Identifiable {
    var id = UUID()
    
    // UI text name of the Tag
    var name: String
    
    // Exported and stored in database as hexadecimal string
    @Attribute(.transformable(by: ColorValueTransformer.self))
    var color: Color
    
    init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
}

extension Tag: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(color.toHexadecimal())
    }
}

extension Tag: Equatable {
    static func ==(lhs: Tag, rhs: Tag) -> Bool {
        return lhs.name == rhs.name && lhs.color.toHexadecimal() == rhs.color.toHexadecimal()
    }
}
