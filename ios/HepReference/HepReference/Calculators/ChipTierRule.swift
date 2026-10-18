import Foundation

/// Highest-priority tier with any chip checked wins (croup's CDS 1→4 severity
/// ladder). An optional override group — croup's "alternate diagnosis" flags —
/// takes priority over every tier when any of its items are checked.
struct ChipTierRule: VerdictRule, Decodable {
    struct Tier: Decodable {
        let key: String
        let items: [String]
        let band: VerdictBand
        let text: String
    }

    struct Override: Decodable {
        let items: [String]
        let band: VerdictBand
        let text: String
    }

    /// Ascending priority — later tiers win when multiple have a chip checked.
    let tiers: [Tier]
    let override: Override?
    let noneBand: VerdictBand
    let noneText: String

    func verdict(selected: Set<String>) -> Verdict {
        if let override {
            let count = override.items.filter(selected.contains).count
            if count > 0 {
                return Verdict(band: override.band, text: override.text.verdictText(count: count))
            }
        }
        for tier in tiers.reversed() where tier.items.contains(where: selected.contains) {
            return Verdict(band: tier.band, text: tier.text)
        }
        return Verdict(band: noneBand, text: noneText)
    }
}
