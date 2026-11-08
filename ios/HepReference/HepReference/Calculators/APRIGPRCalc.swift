import Foundation

/// A published reference point for APRI or GPR. None is a validated
/// pediatric fibrosis threshold: each holds only in the population named.
struct FibrosisIndexReference: Equatable, Identifiable {
    let threshold: Double
    /// The threshold as published ("0.264", "0.5", "1.0", "0.20").
    let thresholdText: String
    /// What a value above the threshold meant in that study or guideline.
    let meaning: String
    /// The population the threshold came from.
    let population: String

    var id: String { thresholdText + " · " + population }
}

/// `c_apri_gpr`: APRI = (AST ÷ AST ULN) ÷ platelets (10⁹/L) × 100 (Wai 2003);
/// GPR = (GGT ÷ GGT ULN) ÷ platelets (10⁹/L) × 100 (Lemoine 2016).
enum APRIGPRCalc {
    /// `guidelines.json` ids shown under the calculator.
    static let sourceIds = ["wai_2003_apri", "lemoine_2016_gpr", "leung_2015_cf_apri", "calvopina_2022_cf_gpr",
                            "who_2024_hbv", "kalveram_2024_peds_scores", "aasld_2025_blood_nilda",
                            "aasld_2025_masld_peds", "espghan_2026_masld"]

    /// (value ÷ ULN) ÷ platelets × 100, as one division of exact products
    /// so a value exactly on a threshold stays exact. Nil for any input ≤ 0.
    static func index(value: Double, uln: Double, platelets: Double) -> Double? {
        guard value > 0, uln > 0, platelets > 0 else { return nil }
        return (value * 100) / (uln * platelets)
    }

    /// APRI reference points: CF liver disease (Leung 2015, 67 biopsied CF
    /// children vs 104 CF controls) and chronic HBV in adults and
    /// adolescents (WHO 2024).
    static let apriReferences: [FibrosisIndexReference] = [
        FibrosisIndexReference(threshold: 0.264, thresholdText: "0.264",
                               meaning: "In CF: liver disease likely (sensitivity 73%, specificity 70%)",
                               population: "Children with cystic fibrosis (CF) · Leung 2015"),
        FibrosisIndexReference(threshold: 0.5, thresholdText: "0.5",
                               meaning: "In hepatitis B: significant fibrosis (≥ F2), a treatment criterion",
                               population: "Chronic hepatitis B, adolescents and adults · WHO 2024"),
        FibrosisIndexReference(threshold: 1.0, thresholdText: "1.0", meaning: "In hepatitis B: cirrhosis",
                               population: "Chronic hepatitis B, adolescents and adults · WHO 2024"),
    ]

    /// GPR reference point: CF liver disease (Calvopina 2022, 237 children).
    static let gprReferences: [FibrosisIndexReference] = [
        FibrosisIndexReference(threshold: 0.20, thresholdText: "0.20",
                               meaning: "In CF: liver disease likely (sensitivity 74%, specificity 73%)",
                               population: "Children with cystic fibrosis (CF) · Calvopina 2022"),
    ]

    /// Strictly above: the studies define a positive result as "> cut-off".
    static func isAbove(_ value: Double, _ reference: FibrosisIndexReference) -> Bool {
        value > reference.threshold
    }

    /// Two decimals, rounded half up — more (up to six) when two would put
    /// the shown number on the other side of a reference point than the
    /// value itself, so "0.50" never sits next to "Above 0.5".
    static func format(_ value: Double, near references: [FibrosisIndexReference] = []) -> String {
        var text = ""
        for places in 2...6 {
            let scale = pow(10, Double(places))
            let shown = (value * scale).rounded() / scale
            text = String(format: "%.\(places)f", shown)
            if references.allSatisfy({ isAbove(shown, $0) == isAbove(value, $0) && (shown == $0.threshold) == (value == $0.threshold) }) {
                return text
            }
        }
        return text
    }
}
