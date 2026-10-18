import Foundation

/// Checks an ordered list of tiers; the first tier with any of its keys
/// selected wins. Covers every "any item in group X → banner Y" calculator
/// (snoop, brue, nexus, tlsind, conrf — single tier; fyi, hb, apap, dka, fn —
/// 2-3 ordered tiers). `text` may use the `{n}`/`{s}` count template.
struct ChecklistAnyRule: VerdictRule, Decodable {
    struct Tier: Decodable {
        let band: VerdictBand
        let keys: [String]
        let text: String
    }

    let tiers: [Tier]
    let noneBand: VerdictBand
    let noneText: String

    func verdict(selected: Set<String>) -> Verdict {
        for tier in tiers {
            let count = tier.keys.filter(selected.contains).count
            if count > 0 {
                return Verdict(band: tier.band, text: tier.text.verdictText(count: count))
            }
        }
        return Verdict(band: noneBand, text: noneText)
    }
}
