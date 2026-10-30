import Foundation

/// Liver-injury pattern from the R ratio (ACG 2021, AASLD 2023 and EASL
/// 2019 DILI guidance; lesson 01-01).
enum InjuryPattern: Equatable {
    case hepatocellular
    case mixed
    case cholestatic

    /// R ≥ 5 hepatocellular, R ≤ 2 cholestatic, in between mixed.
    init(r: Double) {
        if r >= 5 {
            self = .hepatocellular
        } else if r <= 2 {
            self = .cholestatic
        } else {
            self = .mixed
        }
    }

    var label: String {
        switch self {
        case .hepatocellular: "Hepatocellular · R ≥ 5"
        case .mixed: "Mixed · R > 2 to < 5"
        case .cholestatic: "Cholestatic · R ≤ 2"
        }
    }

    /// Typical causes, lesson 01-01 slide 3.
    var causes: String {
        switch self {
        case .hepatocellular: "Viral, autoimmune, Wilson disease, DILI, ischemia."
        case .mixed: "Infiltration, DILI, early obstruction."
        case .cholestatic: "Obstruction, sclerosing cholangitis, drugs."
        }
    }
}

struct RRatioResult: Equatable {
    let r: Double
    let pattern: InjuryPattern
    /// "New R": the higher of ALT or AST (each ÷ its ULN) over ALP ÷ ULN.
    /// Nil unless both AST and its ULN were given.
    let nR: Double?
    let nRPattern: InjuryPattern?
    /// ALT (and AST, if given) and ALP all at or under their ULN: R then
    /// names no pattern worth acting on.
    let allWithinULN: Bool
}

/// `c_rratio`: R = (ALT ÷ ULN) ÷ (ALP ÷ ULN).
enum RRatioCalc {
    /// `guidelines.json` ids shown under the calculator.
    static let sourceIds = ["acg_2021_dili", "aasld_2023_dili", "easl_2019_dili", "molleston_2011_dilin", "robles_diaz_2014_nr"]

    static func compute(alt: Double, altULN: Double, alp: Double, alpULN: Double,
                        ast: Double? = nil, astULN: Double? = nil) -> RRatioResult? {
        guard alt > 0, altULN > 0, alp > 0, alpULN > 0 else { return nil }
        // One division of two exact products, not three chained divisions:
        // with integer lab values an R of exactly 5 or 2 stays exact and
        // lands in the right pattern (ALT 374/40, ALP 561/300 is R = 5).
        let r = (alt * alpULN) / (altULN * alp)
        var nR: Double?
        var astWithinULN = true
        if let ast, let astULN, ast > 0, astULN > 0 {
            let astR = (ast * alpULN) / (astULN * alp)
            nR = max(r, astR)
            astWithinULN = ast <= astULN
        }
        return RRatioResult(r: r, pattern: InjuryPattern(r: r), nR: nR, nRPattern: nR.map(InjuryPattern.init(r:)),
                            allWithinULN: alt <= altULN && alp <= alpULN && astWithinULN)
    }

    /// R as shown: truncated to two decimals ("4.99" for 4.996), so an R
    /// just under 5 never prints as "5.00" next to "Mixed".
    static func format(_ r: Double) -> String {
        String(format: "%.2f", (r * 100).rounded(.down) / 100)
    }
}
