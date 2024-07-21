import Foundation
import SwiftUI

@objc(ColorValueTransformer)
public final class ColorValueTransformer: ValueTransformer {
    // Writing (to DB)
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
    }

    // Reading (from DB)
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
    }
    
    /// class of the "output" objects, as returned by transformedValue:
    override public class func transformedValueClass() -> AnyClass {
        return UIColor.self
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
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName("ColorValueTransformer"))
    }
}

final class MeasurementTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        // Need to use NSMeasurement rather than Measurement as the latter doesn't
        // conform to NSSecureCoding.
        // This doesn't cause any problems in practice (as far as I can tell)
        // as the classes are interchangeable
        guard let measurement = value as? NSMeasurement else { return nil }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: measurement, requiringSecureCoding: true)
            return data
        } catch {
            debugPrint("Unable to convert Measurement to a persistable form: \(error.localizedDescription)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let measurement = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSMeasurement.self, from: data)
            return measurement
        } catch {
            debugPrint("Unable to convert persisted Data to a Measurement type: \(error.localizedDescription)")
            return nil
        }
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override class func transformedValueClass() -> AnyClass {
        NSMeasurement.self
    }
}
