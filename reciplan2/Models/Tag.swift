import Foundation
import Combine
import UIKit
import SwiftUI
import SwiftData

// MARK: - Tag
@Model
class Tag: Identifiable {
    let id = UUID()
    // UI text name of the Tag
    var name: String
    // Exported and stored in database as hexadecimal string
    // var color: Color
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

//extension Tag: Codable {
//    // MARK: - JSON encoding, decoding for sharing recipes
//    private enum CodingKeys: CodingKey {
//        case name, color
//    }
//    
//    init(from decoder: Decoder) throws {
//        let values  = try decoder.container(keyedBy: CodingKeys.self)
//        let name    = try values.decode(String.self, forKey: .name)
//        let color   = try values.decode(String.self, forKey: .color)
//        self.init(name: name, color: Color(hex: color))
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        try container.encode(color.toHexadecimal(), forKey: .color)
//    }
//}
