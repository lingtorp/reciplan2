import SwiftUI
import SwiftData

// MARK: - Tag
@Model
final class Tag: Identifiable {
    var id = UUID()
    
    // UI text name of the Tag
    var name: String
    
    @Attribute(.transformable(by: ColorValueTransformer.self))
    private var _color: UIColor
    
    var color: Color {
        get {
            Color(uiColor: _color)
        }
        set(newValue) {
            _color = UIColor(newValue)
        }
    }
    
    init(name: String, color: Color) {
        self.name = name
        self._color = UIColor(color)
    }
}

extension Tag: Equatable {
    static func ==(lhs: Tag, rhs: Tag) -> Bool {
        return lhs.name == rhs.name && lhs.color == rhs.color
    }
}
