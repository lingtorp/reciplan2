import SwiftUI
import SwiftData
import UIKit
import Foundation

// MARK: - Measurement
struct Measurement: Codable, Hashable {
    // Formatter used to display measurement quantities
    public static let numberFormatter = Measurement.newNumberFormatter()
    private static func newNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.alwaysShowsDecimalSeparator = false
        formatter.maximumIntegerDigits = 4
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter
    }

    var quantity: Float?
    var unit: MeasurementUnit
    
    // Returns volumes in mls, weights in grams for comparisons over measurement systems
    public var normalizedQuantity: Float {
        return MeasurementUnit.convert(from: unit, quantity: quantity ?? 0, to: unit.principalUnit) ?? 0
    }
        
    // Returns the largest whole unit in the correct family measurement system
    // Example: (1200 ml -> 1.2 l)
    public func normalized(in system: MeasurementSystem, scale: Float = 1.0) -> Measurement {
        let scaled = scale * (quantity ?? 0)
        guard let quant = MeasurementUnit.convert(from: unit, quantity: scaled, to: unit.principalUnit) else { return self }
        let units = unit.familyMembers(in: system)
        
        var converted = units.map { unit in
            Measurement(quantity: quant / unit.quantity, unit: unit)
        }
                
        converted.sort { $0.quantity ?? 0 < $1.quantity ?? 0 }
        
        if let normalized = converted.first(where: { x in x.quantity ?? 0 >= 1.0 }) {
            return normalized
        }
        
        return converted.last ?? self // Valid for some .misc types
    }
    
    // Normalized in user preferred measurement system
    public func normalized() -> Measurement {
        guard let userPreferredSystem = MeasurementSystem(rawValue: UserDefaults.standard.integer(forKey: "measurementSystem")) else { return self }
        return self.normalized(in: userPreferredSystem)
    }
    
    // Adds two measurements quantity and units in a correct normalized way
    // Mixing measurement system returns Measurement in user preferred measurement system
    public static func add(_ lhs: Measurement, _ rhs: Measurement) -> Measurement {
        guard let lhsQuant = MeasurementUnit.convert(from: lhs.unit, quantity: lhs.quantity, to: lhs.unit.principalUnit) else { return lhs }
        guard let rhsQuant = MeasurementUnit.convert(from: rhs.unit, quantity: rhs.quantity, to: rhs.unit.principalUnit) else { return rhs }
        #if DEBUG
        assert(lhs.unit.measurementType == rhs.unit.measurementType) // Must be same measurement type and thus principal unit
        #else
        guard lhs.unit.measurementType == rhs.unit.measurementType else { return lhs }
        #endif
        return Measurement(quantity: lhsQuant + rhsQuant, unit: lhs.unit.principalUnit).normalized()
    }
    
    public static func add(_ left: Measurement?, _ right: Measurement) -> Measurement {
        guard let lhs = left else { return right }
        return Measurement.add(lhs, right)
    }
    
    public static func add(_ left: Measurement, _ right: Measurement?) -> Measurement {
        guard let rhs = right else { return left }
        return Measurement.add(left, rhs)
    }
}
