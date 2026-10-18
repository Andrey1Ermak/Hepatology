import Foundation

/// Plain tally of checked items (no per-item weighting) with an optional
/// special key that forces the top band regardless of count — intuss's only
/// user (blood per rectum instantly means "high concern" even alone).
struct ChipCountRule: VerdictRule, Decodable {
    struct Threshold: Decodable {
        let minCount: Int
        let band: VerdictBand
        let text: String

        private enum CodingKeys: String, CodingKey { case minCount = "min_count", band, text }
    }

    let specialKey: String?
    let specialBand: VerdictBand?
    let specialText: String?
    /// Checked in descending `minCount` order; must include a `min_count: 0`
    /// entry to cover "nothing marked".
    let thresholds: [Threshold]

    private enum CodingKeys: String, CodingKey {
        case specialKey = "special_key", specialBand = "special_band", specialText = "special_text"
        case thresholds
    }

    func verdict(selected: Set<String>) -> Verdict {
        if let specialKey, selected.contains(specialKey), let specialBand, let specialText {
            return Verdict(band: specialBand, text: specialText)
        }
        let count = selected.count
        let threshold = thresholds.first { count >= $0.minCount } ?? thresholds.last!
        return Verdict(band: threshold.band, text: threshold.text.verdictText(count: count))
    }
}
