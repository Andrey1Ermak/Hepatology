import Foundation
import Observation

/// One guideline or primary source (`Registry/guidelines.json`). Cards cite
/// it by `id`; this file is the only place its title, year and citation live.
struct Guideline: Identifiable, Decodable {
    let id: String
    let title: String
    let society: String
    let year: Int
    let citation: String
    let url: String?
    /// Month the team last checked for a newer version, "YYYY-MM".
    let checked: String
    /// Id of the older guideline this one replaces.
    let supersedes: String?
}

/// One analyte's age- and sex-specific limits (`Registry/labs.json`).
struct LabTest: Identifiable, Decodable {
    let id: String
    let name: String
    let unit: String
    /// What the limits mean and where they stop applying (a health-based
    /// cut-off versus a laboratory interval, assay dependence). Shown under
    /// the analyte's table.
    let note: String?
    let bands: [LabBand]
}

extension LabTest {
    /// Heading of the limit column: "ULN" when every band is an upper limit
    /// only (a health-based cut-off), otherwise "Range".
    var limitHeading: String {
        bands.allSatisfy { $0.low == nil } ? "ULN" : "Range"
    }
}

struct LabBand: Decodable {
    /// An `AgeBand` raw value or a finer label the analyte needs.
    let age: String
    /// The `AgeBand` a finer label ("0–7 d", "1–3 y") falls inside, so the
    /// row can still be highlighted for the card's chosen age.
    let within: AgeBand?
    /// Nil when the limit is the same for both sexes.
    let sex: Sex?
    let low: Double?
    let high: Double?
    /// Id into `guidelines.json`.
    let source: String
}

extension LabBand {
    /// Age column: the `AgeBand` chip label ("11–18 y"), or the finer label
    /// as written in `labs.json`.
    var ageLabel: String {
        AgeBand(rawValue: age)?.label ?? age
    }

    /// Sex column; "All" when the limit applies to both sexes.
    var sexLabel: String {
        switch sex {
        case .F: "F"
        case .M: "M"
        case nil: "All"
        }
    }

    /// The reference interval as shown: "7–22", "≤ 22.1" or "≥ 150".
    var rangeText: String {
        switch (low, high) {
        case let (low?, high?): "\(Self.format(low))–\(Self.format(high))"
        case let (nil, high?): "≤ \(Self.format(high))"
        case let (low?, nil): "≥ \(Self.format(low))"
        case (nil, nil): "—"
        }
    }

    /// The `AgeBand` this row belongs to: its own age when that is an
    /// `AgeBand` value, otherwise `within`.
    var ageBand: AgeBand? {
        AgeBand(rawValue: age) ?? within
    }

    /// True when this band belongs to the age the card has selected. Several
    /// finer bands inside one `AgeBand` all match it.
    func matches(_ selected: AgeBand?) -> Bool {
        selected != nil && ageBand == selected
    }

    /// Limits as published: up to two decimals, trailing zeros trimmed,
    /// thousands grouped with commas ("26", "22.1", "0.15", "190,546").
    /// The integrity gate checks that every bundled limit survives this
    /// unchanged.
    static func format(_ value: Double) -> String {
        var text = String(format: "%.2f", value)
        while text.hasSuffix("0") { text.removeLast() }
        if text.hasSuffix(".") { text.removeLast() }
        let sign = text.hasPrefix("-") ? "-" : ""
        let parts = text.dropFirst(sign.count).split(separator: ".", maxSplits: 1)
        var whole = String(parts[0])
        var index = whole.endIndex
        while whole.distance(from: whole.startIndex, to: index) > 3 {
            index = whole.index(index, offsetBy: -3)
            whole.insert(",", at: index)
        }
        return sign + (parts.count > 1 ? "\(whole).\(parts[1])" : whole)
    }

    /// The range as VoiceOver should say it: "9,120 to 190,546".
    var spokenRange: String {
        switch (low, high) {
        case let (low?, high?): "\(Self.format(low)) to \(Self.format(high))"
        case let (nil, high?): "up to \(Self.format(high))"
        case let (low?, nil): "at least \(Self.format(low))"
        case (nil, nil): "no limit"
        }
    }

    /// Reads back a `format` result for the integrity gate. Accepts only
    /// well-formed text — commas exactly every three digits — so a
    /// misplaced separator fails the gate instead of round-tripping.
    static func parse(_ text: String) -> Double? {
        guard text.wholeMatch(of: #/-?\d{1,3}(,\d{3})*(\.\d{1,2})?/#) != nil else { return nil }
        return Double(text.replacingOccurrences(of: ",", with: ""))
    }
}

enum Sex: String, Decodable {
    case F
    case M
}

/// One two-week block of the year plan (`Registry/plan.json`).
struct PlanBlock: Identifiable, Decodable {
    let block: Int
    let title: String
    /// First day of the block, "YYYY-MM-DD".
    let start: String
    let days: [PlanDay]

    var id: Int { block }
}

struct PlanDay: Decodable {
    let day: Int
    let topic: String
    /// Cards this lesson feeds.
    let cards: [String]
}

/// A "Test yourself" case (`Registry/cases.json`).
struct ClinicalCase: Identifiable, Decodable {
    let id: String
    let card: String
    let stem: String
    let question: String
    let answer: String
    let teaching: String?
}

/// Loads the shared registries under `Content/Registry/` once at launch.
/// A missing or malformed file leaves its registry empty; the
/// `ContentIntegrityTests` gate catches that before release.
@Observable
final class Registry {
    private(set) var guidelines: [Guideline] = []
    private(set) var labs: [LabTest] = []
    private(set) var plan: [PlanBlock] = []
    private(set) var cases: [ClinicalCase] = []
    /// Search term → alternative spellings, abbreviations and translations.
    private(set) var synonyms: [String: [String]] = [:]

    init(bundle: Bundle = .main) {
        guidelines = Self.load("guidelines", bundle: bundle) ?? []
        labs = Self.load("labs", bundle: bundle) ?? []
        plan = Self.load("plan", bundle: bundle) ?? []
        cases = Self.load("cases", bundle: bundle) ?? []
        synonyms = Self.load("synonyms", bundle: bundle) ?? [:]
    }

    static func load<T: Decodable>(_ name: String, bundle: Bundle) -> T? {
        guard let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "Content/Registry"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func guideline(_ id: String) -> Guideline? {
        guidelines.first { $0.id == id }
    }

    func lab(_ id: String) -> LabTest? {
        labs.first { $0.id == id }
    }

    func cases(forCard cardId: String) -> [ClinicalCase] {
        cases.filter { $0.card == cardId }
    }
}
