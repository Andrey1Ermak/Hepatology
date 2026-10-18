import Foundation

/// Sums per-item points and matches the highest band whose `minScore` the
/// total meets. Covers both weighted items and uniform 1 pt/item
/// scores; two bands may share the same `band` color with different guidance
/// text.
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
