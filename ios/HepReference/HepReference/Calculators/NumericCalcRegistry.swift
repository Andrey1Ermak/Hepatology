import SwiftUI

/// The single list of Swift-implemented `numeric_calc` calculators. To add
/// one: write `<Name>Calc.swift` (pure function, unit-tested) and
/// `Views/Calculators/<Name>CalcView.swift`, then register its id here —
/// `BlockView`, `NumericCalcSheet` and `ContentIntegrityTests` all read
/// from this list, so there is nothing else to update.
enum NumericCalcRegistry {
    static let ids: Set<String> = ["nac", "c_uln", "c_rratio"]

    /// Default sheet title when a calculator is opened without a card's
    /// `numeric_calc` label (e.g. the DEBUG `-hepOpenCalc` launch argument).
    static func title(for calcId: String) -> String {
        switch calcId {
        case "nac": "Acetaminophen: 21-h IV NAC"
        case "c_uln": "Liver enzymes × ULN"
        case "c_rratio": "R ratio: injury pattern"
        default: calcId
        }
    }

    static func view(for calcId: String) -> AnyView? {
        switch calcId {
        case "nac": AnyView(NACCalcView())
        case "c_uln": AnyView(ULNCalcView())
        case "c_rratio": AnyView(RRatioCalcView())
        default: nil
        }
    }
}
