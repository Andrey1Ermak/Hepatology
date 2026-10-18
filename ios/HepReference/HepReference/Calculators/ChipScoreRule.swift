import Foundation

/// Sums per-item points and matches the highest band whose `minScore` the
/// total meets. Covers pibis (weighted: 1/1/1/2 pts) and kd (uniform 1 pt/item,
/// both its thresholds happen to band "hi" — that's the real card_audit.md
/// behavior, not a bug: incomplete-KD and complete-KD are both urgent, just
/// with different guidance text).
struct ChipScoreRule: VerdictRule, Decodable {
    struct Band: Decodable {
        let minScore: Int
        let band: VerdictBand
        let text: String

        private enum CodingKeys: String, CodingKey { case minScore = "min_score", band, text }
    }

    let points: [String: Int]
    /// Checked in descending `minScore` order by the caller; JSON lists them
    /// highest-first to match that.
    let bands: [Band]

    func verdict(selected: Set<String>) -> Verdict {
        let total = selected.reduce(0) { $0 + (points[$1] ?? 0) }
        let band = bands.first { total >= $0.minScore } ?? bands.last!
        return Verdict(band: band.band, text: band.text.verdictText(count: total))
    }
}
