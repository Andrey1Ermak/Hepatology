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
    let bands: [LabBand]
}

struct LabBand: Decodable {
    /// An `AgeBand` raw value or a finer label the analyte needs.
    let age: String
    /// Nil when the limit is the same for both sexes.
    let sex: Sex?
    let low: Double?
    let high: Double?
    /// Id into `guidelines.json`.
    let source: String
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
