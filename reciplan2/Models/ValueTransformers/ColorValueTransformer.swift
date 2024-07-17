import Foundation
import SwiftUI

@objc(ColorValueTransformer)
public final class ColorValueTransformer: ValueTransformer {
    // Input (to DB)
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? Color else { return nil }
        guard let data = color.toHexadecimal().data(using: .utf8) else { return nil }
        return NSData(data: data)
    }

    // Output (from DB)
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        guard let string = String(data: data, encoding: .utf8) else { return nil }
        return Color(hex: string)
    }
    
    /// class of the "output" objects, as returned by transformedValue:
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
