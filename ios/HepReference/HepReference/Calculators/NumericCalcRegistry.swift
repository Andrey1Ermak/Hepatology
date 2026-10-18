import SwiftUI

/// The single list of Swift-implemented `numeric_calc` calculators. To add
/// one: write `<Name>Calc.swift` (pure function, unit-tested) and
/// `Views/Calculators/<Name>CalcView.swift`, then register its id here —
/// `BlockView`, `NumericCalcSheet` and `ContentIntegrityTests` all read
/// from this list, so there is nothing else to update.
enum NumericCalcRegistry {
    static let ids: Set<String> = ["nac"]

    static func view(for calcId: String) -> AnyView? {
        switch calcId {
        case "nac": AnyView(NACCalcView())
        default: nil
        }
    }
}
