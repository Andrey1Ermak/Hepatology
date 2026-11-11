import Foundation

/// `c_conj_bili`: is this direct or conjugated bilirubin cholestasis?
/// NASPGHAN/ESPGHAN 2017 (Fawaz, abstract): direct > 1.0 mg/dL (17 µmol/L)
/// is abnormal at any total. Harpavat 2011: every newborn with atresia who
/// was tested had a value above the lab range, and 79% had a direct:total
/// ratio ≤ 0.2 — so the calculator never gives a ratio-based verdict, and a
/// value above the lab's own range is never called normal (D-2026-11-11-2).
enum ConjBiliCalc {
    static let sourceIds = ["naspghan_espghan_2017_nc", "harpavat_2011_ba_screen", "nice_cg98_2010"]

    enum Unit: String, CaseIterable, Equatable {
        case mgdl = "mg/dL"
        case umol = "µmol/L"

        /// The cholestasis threshold in this unit, as Fawaz 2017 prints both
        /// (1.0 mg/dL, 17 µmol/L). Inclusive, so a value on the line is never
        /// called normal. 17 µmol/L is 0.994 mg/dL, so 17.0–17.09 µmol/L is
        /// cholestasis while its exact mg/dL twin is not — intended: the
        /// published number in the unit the lab reports wins.
        var threshold: Double {
            switch self {
            case .mgdl: 1.0
            case .umol: 17
            }
        }

        /// "1.0 mg/dL" / "17 µmol/L".
        var thresholdLabel: String {
            switch self {
            case .mgdl: "1.0 mg/dL"
            case .umol: "17 µmol/L"
            }
        }
    }

    enum Age: CaseIterable, Equatable {
        case under2Weeks, twoWeeksOrOlder

        var label: String {
            switch self {
            case .under2Weeks: "Under 2 weeks"
            case .twoWeeksOrOlder: "2 weeks or older"
            }
        }
    }

    enum Verdict: Equatable {
        /// Pale stool or dark urine: same-day evaluation whatever the number.
        case paleStool
        /// At or above the threshold: cholestasis.
        case cholestasis
        /// Under 2 weeks, below the threshold but above the lab's limit:
        /// repeat by the 2-week visit.
        case aboveLabRangeNewborn
        /// 2 weeks or older (or age not given), below the threshold but above
        /// the lab's limit: still jaundiced past 2 weeks with a raised value
        /// → discuss with hepatology today (matches the Unconjugated
        /// Hyperbilirubinemia card).
        case aboveLabRangeOlder
        /// Below the threshold and within the lab's range.
        case withinLabRange
        /// Below the threshold; no lab upper limit entered.
        case belowThresholdNoULN
    }

    struct Result: Equatable {
        let verdict: Verdict
        /// Direct ÷ total, shown only as context; nil without both values.
        let fraction: Double?
        /// Direct greater than total: an entry error.
        let directExceedsTotal: Bool
        /// Lab limit at or above the cholestasis threshold: probably typed
        /// in the other unit (a µmol/L limit on the mg/dL setting).
        let labULNSuspect: Bool
    }

    private static func valid(_ x: Double?) -> Double? {
        x.flatMap { $0 > 0 && $0.isFinite ? $0 : nil }
    }

    /// Nil when neither a valid direct value nor pale stool is given. Zero,
    /// negative or non-finite inputs are treated as absent. Pale stool
    /// overrides everything, even with no number yet.
    static func compute(direct: Double?, unit: Unit, total: Double? = nil, labULN: Double? = nil,
                        age: Age? = nil, paleStool: Bool = false) -> Result? {
        let direct = valid(direct), total = valid(total), labULN = valid(labULN)
        let verdict: Verdict
        if paleStool {
            verdict = .paleStool
        } else if let direct {
            if direct >= unit.threshold {
                verdict = .cholestasis
            } else if let labULN {
                if direct > labULN {
                    verdict = age == .under2Weeks ? .aboveLabRangeNewborn : .aboveLabRangeOlder
                } else if labULN >= unit.threshold {
                    // A limit that high was probably typed in the other
                    // unit: never reassure on it.
                    verdict = .belowThresholdNoULN
                } else {
                    verdict = .withinLabRange
                }
            } else {
                verdict = .belowThresholdNoULN
            }
        } else {
            return nil
        }
        var fraction: Double?
        var exceeds = false
        if let direct, let total {
            fraction = direct / total
            exceeds = direct > total
        }
        return Result(verdict: verdict, fraction: fraction, directExceedsTotal: exceeds,
                      labULNSuspect: labULN.map { $0 >= unit.threshold } ?? false)
    }

    /// "12%" — the fraction is context only, rounded to a whole percent.
    static func formatPercent(_ fraction: Double) -> String {
        "\(Int((fraction * 100).rounded()))%"
    }
}
