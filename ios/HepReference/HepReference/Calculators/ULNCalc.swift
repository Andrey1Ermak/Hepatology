import Foundation

/// The liver enzymes `c_uln` expresses as a multiple of the upper limit of
/// normal. Raw values are `labs.json` ids.
enum LiverEnzyme: String, CaseIterable, Identifiable {
    case alt
    case ast
    case ggt
    case alp

    var id: String { rawValue }

    var name: String { rawValue.uppercased() }

    /// ACG grades only the aminotransferases.
    var isAminotransferase: Bool { self == .alt || self == .ast }
}

/// ACG 2017 magnitude bands for a raised ALT or AST (Kwo 2017, adult
/// guideline used by lesson 01-01 for children). `withinULN` is not an ACG
/// band — it is shown so a value at or under the ULN is not called
/// "borderline".
enum AminotransferaseGrade: Equatable {
    case withinULN
    case borderline
    case mild
    case moderate
    case severe
    case massive

    var label: String {
        switch self {
        case .withinULN: "Within ULN"
        case .borderline: "Borderline · < 2 × ULN"
        case .mild: "Mild · 2–5 × ULN"
        case .moderate: "Moderate · 5–15 × ULN"
        case .severe: "Severe · > 15 × ULN"
        case .massive: "Massive · > 10,000 U/L · check CK"
        }
    }
}

/// `c_uln`: an enzyme as a multiple of the ULN for age and sex.
enum ULNCalc {
    /// `guidelines.json` ids always shown under the calculator; the
    /// reference band adds its own source.
    static let sourceIds = ["kwo_2017_acg_lft", "bsg_2018_lft"]

    /// value ÷ ULN. Nil unless the ULN is positive and the value is not negative.
    static func multiple(value: Double, uln: Double) -> Double? {
        guard uln > 0, value >= 0 else { return nil }
        return value / uln
    }

    /// The health-based ULN the app holds for this enzyme, age and sex, from
    /// `labs.json` — only bands written for a whole `AgeBand` with an upper
    /// limit count (finer bands such as "Day 3" are not ULNs for an age
    /// group). Nil means "use the laboratory's ULN".
    static func reference(in labs: [LabTest], enzyme: LiverEnzyme, age: AgeBand?, sex: Sex?) -> LabBand? {
        guard let age, let sex, let test = labs.first(where: { $0.id == enzyme.rawValue }) else { return nil }
        return test.bands.first { band in
            band.age == age.rawValue && band.high != nil && (band.sex == nil || band.sex == sex)
        }
    }

    /// ACG grade for an aminotransferase; nil for GGT and ALP. Boundaries:
    /// exactly 2 × is mild, exactly 5 × mild, exactly 15 × moderate
    /// (D-2026-10-30-2). An absolute value over 10,000 U/L is massive
    /// whatever the ULN.
    static func grade(enzyme: LiverEnzyme, value: Double, multiple: Double) -> AminotransferaseGrade? {
        guard enzyme.isAminotransferase else { return nil }
        if value > 10_000 { return .massive }
        switch multiple {
        case ...1: return .withinULN
        case ..<2: return .borderline
        case ...5: return .mild
        case ...15: return .moderate
        default: return .severe
        }
    }

    /// Multiples as shown: truncated to two decimals ("1.99" for 1.996), so a
    /// value just under a band edge never prints as the edge itself.
    static func format(_ multiple: Double) -> String {
        String(format: "%.2f", (multiple * 100).rounded(.down) / 100)
    }
}
