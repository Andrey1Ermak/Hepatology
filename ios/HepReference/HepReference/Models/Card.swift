import Foundation

/// Acuity level, drives badge color: crit=red, urg=orange, rt=green, ref=navy.
enum AcuLevel: String, Decodable {
    case crit
    case urg
    case rt
    case ref
}

/// Age band a card covers: neo 0–28 d, infant 1–12 mo, child 1–10 y, teen 11–18 y.
enum AgeBand: String, Decodable, CaseIterable {
    case neo
    case infant
    case child
    case teen
}

/// How a fellow arrives at the card — by a lab value, a symptom, a clinical
/// situation, a suspected disease, or as plain reference.
enum EntryPoint: String, Decodable {
    case lab
    case symptom
    case situation
    case disease
    case reference
}

/// Editorial status: `draft` → `reviewed` (checked on device) → `approved`
/// (set only by the author, if he chooses to).
enum CardStatus: String, Decodable {
    case draft
    case reviewed
    case approved
}

/// A link to the year plan: one block and the days within it that cover the card.
struct PlanRef: Decodable, Equatable {
    let block: Int
    let days: [Int]
}

struct Card: Identifiable, Decodable {
    let id: String
    let title: String
    let code: String
    let cat: CardCategory
    let acu: AcuLevel
    let src: String?
    let tags: [String]
    /// Optional metadata (CLAUDE.md §5.1) — absent fields decode as nil so
    /// cards written before they existed still load.
    let ages: [AgeBand]?
    let entry: EntryPoint?
    /// Ids into `Registry/guidelines.json`.
    let guidelines: [String]?
    let plan: [PlanRef]?
    /// Ids of sibling cards.
    let related: [String]?
    let status: CardStatus?
    let blocks: [Block]

    /// For tests and previews; bundled cards come from JSON.
    init(
        id: String,
        title: String,
        code: String,
        cat: CardCategory,
        acu: AcuLevel,
        src: String? = nil,
        tags: [String] = [],
        ages: [AgeBand]? = nil,
        entry: EntryPoint? = nil,
        guidelines: [String]? = nil,
        plan: [PlanRef]? = nil,
        related: [String]? = nil,
        status: CardStatus? = nil,
        blocks: [Block] = []
    ) {
        self.id = id
        self.title = title
        self.code = code
        self.cat = cat
        self.acu = acu
        self.src = src
        self.tags = tags
        self.ages = ages
        self.entry = entry
        self.guidelines = guidelines
        self.plan = plan
        self.related = related
        self.status = status
        self.blocks = blocks
    }
}
