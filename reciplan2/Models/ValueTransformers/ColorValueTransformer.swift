import Foundation
import SwiftUI

/// A value transformer which transforms `Color` instances into `NSData` using `NSSecureCoding`.
// FIXME: Should maybe have the color be converted to a hexadecimal string instead like OG Reciplan
@objc(ColorValueTransformer)
public final class ColorValueTransformer: ValueTransformer {
    override public func transformedValue(_ value: Any?) -> Any? {
      guard let color = value as? Color else { return nil }
      
      do {
          let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
          return data
      } catch {
          assertionFailure("Failed to transform `Color` to `Data`")
          return nil
      }
    }

    override public func reverseTransformedValue(_ value: Any?) -> Any? {
      guard let data = value as? NSData else { return nil }
      
      do {
          if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data as Data) {
              return Color(uiColor: color)
          }
          assertionFailure("Failed to transform `Data` to `Color`")
          return nil
      } catch {
          assertionFailure("Failed to transform `Data` to `Color`")
          return nil
      }
    }
    
    override public class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
}

extension ColorValueTransformer {
    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: ColorValueTransformer.self))

    /// Registers the value transformer with `ValueTransformer`.
    public static func register() {
        let transformer = ColorValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
