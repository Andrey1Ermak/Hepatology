import Foundation

/// Verdict banner color: hi=red, mid=orange, lo=green/gray.
enum VerdictBand: String, Decodable {
    case hi, mid, lo
}

struct Verdict: Equatable {
    let band: VerdictBand
    let text: String
}

/// Computes a verdict from the set of currently-checked chip keys. Implemented
/// either declaratively (ChecklistAnyRule/ChipScoreRule/ChipCountRule/ChipTierRule,
/// driven entirely by JSON) or as a named Swift type for logic too irregular to
/// express declaratively (registered by `rule_id` in `ChipScreen.verdictRule`).
protocol VerdictRule {
    func verdict(selected: Set<String>) -> Verdict
}

extension String {
    /// Substitutes `{n}` with the count and `{s}` with an English plural suffix
    /// (`""` for 1, `"s"` otherwise) — verdict copy
    /// consistently pluralizes this way (e.g. "3 red flags", "1 red flag").
    func verdictText(count: Int) -> String {
        replacingOccurrences(of: "{n}", with: String(count))
            .replacingOccurrences(of: "{s}", with: count == 1 ? "" : "s")
    }
}
