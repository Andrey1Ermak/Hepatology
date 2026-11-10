import Foundation

/// `c_vitamins`: starting doses of the fat-soluble vitamins in cholestasis
/// (Mouzaki 2019, NASPGHAN/ESPGHAN, Table 3) for a body weight, plus the
/// bilirubin trigger for separate dosing and closer monitoring (Shneider
/// 2012, ChiLDReN). Only vitamin E is dosed per kilogram; A steps at 10 kg;
/// D and K are fixed ranges.
enum VitaminsCalc {
    /// `guidelines.json` ids shown under the calculator.
    static let sourceIds = ["mouzaki_2019_nutrition", "shneider_2012_fsv"]

    /// Weights the calculator accepts (kg). Outside this range the inputs
    /// are almost certainly a typo (grams, pounds).
    static let weightRange: ClosedRange<Double> = 0.5...150

    /// Vitamin A step: Mouzaki gives 5,000 IU/day "< 10 kg" and 10,000 IU/day
    /// "> 10 kg" without saying where 10 kg itself falls. Exactly 10 kg takes
    /// the lower dose (hypervitaminosis A causes hepatic fibrosis;
    /// D-2026-11-10-2).
    static let vitaminAStepKg = 10.0
    static let vitaminALowIU = 5_000
    static let vitaminAHighIU = 10_000

    /// Vitamin D as cholecalciferol, IU/day, and vitamin K by mouth, mg/day:
    /// fixed ranges, not weight-based (Mouzaki 2019, Table 3).
    static let vitaminDRangeIU = 2_000...5_000
    static let vitaminKRangeMg = 2...5

    /// Total bilirubin the calculator accepts (mg/dL). Above it the value is
    /// almost certainly µmol/L.
    static let bilirubinRange: ClosedRange<Double> = 0...50

    /// Below this weight (the WHO low-birth-weight line) the Table 3 doses
    /// were not written for the child: Mouzaki gives no preterm dose.
    static let termWeightKg = 2.5

    /// Vitamin E as TPGS: 15–25 IU/kg/day.
    static let tpgsLowIUPerKg = 15.0
    static let tpgsHighIUPerKg = 25.0

    /// Total bilirubin at or above which a combined multivitamin fails and
    /// each vitamin is dosed and measured separately (Shneider 2012: 0 of 23
    /// infants with TB ≥ 2 mg/dL sufficient in all four at 6 months). The
    /// paper writes both "> 2" and "≥ 2"; ≥ 2 is used (D-2026-11-10-2).
    static let separateDosingBilirubin = 2.0

    struct Result: Equatable {
        /// Vitamin A, IU/day.
        let vitaminAIU: Int
        /// Vitamin E as TPGS, IU/day (15 and 25 IU/kg, rounded to whole IU).
        let tpgsLowIU: Int
        let tpgsHighIU: Int
        /// Nil when no bilirubin was entered.
        let separateDosing: Bool?
        /// Weight under 2.5 kg: no published starting dose.
        let belowTermWeight: Bool
    }

    /// Nil for a weight outside `weightRange` or a bilirubin outside
    /// `bilirubinRange` (NaN included — never a silent "below 2").
    static func compute(weightKg: Double, totalBilirubin: Double? = nil) -> Result? {
        guard weightRange.contains(weightKg) else { return nil }
        if let tb = totalBilirubin, !bilirubinRange.contains(tb) { return nil }
        return Result(
            vitaminAIU: weightKg > vitaminAStepKg ? vitaminAHighIU : vitaminALowIU,
            tpgsLowIU: Int((weightKg * tpgsLowIUPerKg).rounded()),
            tpgsHighIU: Int((weightKg * tpgsHighIUPerKg).rounded()),
            separateDosing: totalBilirubin.map { $0 >= separateDosingBilirubin },
            belowTermWeight: weightKg < termWeightKg
        )
    }

    /// "5,000" — thousands separated, as the doses are printed in the paper.
    static func formatIU(_ value: Int) -> String {
        value.formatted(.number.locale(Locale(identifier: "en_US")))
    }

    /// "2,000–5,000" — a range of whole units.
    static func formatRange(_ range: ClosedRange<Int>) -> String {
        "\(formatIU(range.lowerBound))–\(formatIU(range.upperBound))"
    }
}
