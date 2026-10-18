import Foundation

struct ScoreOption: Decodable, Equatable {
    let value: String
    let label: String
}

/// An alternate option set shown instead of `options`, when another
/// dimension (`whenKey`) currently holds `whenValue` — only ADS's RR
/// dimension needs this (age-gated breath-rate bands).
struct ConditionalOptionSet: Decodable {
    let whenKey: String
    let whenValue: String
    let options: [ScoreOption]
}

struct ScoreDimension: Decodable {
    let key: String
    let label: String
    let scored: Bool
    let defaultValue: String?
    let options: [ScoreOption]?
    let conditionalOptions: [ConditionalOptionSet]?

    private enum CodingKeys: String, CodingKey {
        case key, label, scored, defaultValue = "default", options
        case conditionalOptions = "conditional_options"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        key = try c.decode(String.self, forKey: .key)
        label = try c.decode(String.self, forKey: .label)
        scored = try c.decodeIfPresent(Bool.self, forKey: .scored) ?? true
        defaultValue = try c.decodeIfPresent(String.self, forKey: .defaultValue)
        options = try c.decodeIfPresent([ScoreOption].self, forKey: .options)
        conditionalOptions = try c.decodeIfPresent([ConditionalOptionSet].self, forKey: .conditionalOptions)
    }

    /// The option set to display right now, resolving `conditionalOptions`
    /// against the current selections of every other dimension.
    func resolvedOptions(selections: [String: String]) -> [ScoreOption] {
        if let options { return options }
        guard let conditionalOptions else { return [] }
        for set in conditionalOptions where selections[set.whenKey] == set.whenValue {
            return set.options
        }
        return conditionalOptions.first?.options ?? []
    }
}

struct ScoreBand: Decodable {
    let min: Int
    let band: VerdictBand
    let label: String
    let tier: String
}

/// A segment-selector score (ADS/BDS/GECDS): N dimensions, each a row of
/// mutually-exclusive point-valued options, summed into a banded verdict.
/// Referenced by a card's `score_calc` block via `calc_id`, e.g.
/// `Content/ScoreCalcs/ads.json`.
struct ScoreCalcSchema: Decodable {
    let id: String
    let maxScore: Int
    let dimensions: [ScoreDimension]
    let bands: [ScoreBand]
    /// `false` for a schema whose point weights are purely an internal
    /// mechanism to land on the right band (e.g. cds's 1/3/6-ish weights,
    /// chosen so a single worst-tier finding alone still crosses the top
    /// band) rather than a real published score — showing "18/28" for one
    /// of those reads as meaningless. `true` (show it) unless a schema opts
    /// out, since ADS/BDS/GECDS's totals ARE real, recognized clinical values.
    let showScore: Bool

    private enum CodingKeys: String, CodingKey {
        case id, maxScore = "max_score", dimensions, bands, showScore = "show_score"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        maxScore = try c.decode(Int.self, forKey: .maxScore)
        dimensions = try c.decode([ScoreDimension].self, forKey: .dimensions)
        bands = try c.decode([ScoreBand].self, forKey: .bands)
        showScore = try c.decodeIfPresent(Bool.self, forKey: .showScore) ?? true
    }

    static func load(calcId: String, bundle: Bundle = .main) -> ScoreCalcSchema? {
        guard let url = bundle.url(forResource: calcId, withExtension: "json", subdirectory: "Content/ScoreCalcs"),
              let data = try? Data(contentsOf: url),
              let schema = try? JSONDecoder().decode(ScoreCalcSchema.self, from: data)
        else { return nil }
        return schema
    }

    /// `bands` must be ordered highest-`min`-first; returns the first (i.e.
    /// highest) band the total qualifies for.
    func band(for total: Int) -> ScoreBand? {
        bands.first { total >= $0.min }
    }
}
