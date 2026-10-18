import Foundation

struct ChipItem: Decodable {
    let key: String
    let label: String
}

/// A labeled, visually-grouped row of chips. `tag` is omitted for a
/// calculator with only one implicit group (whose own
/// `CalculatorHeader` label already says what the chips are). `exclusive`
/// marks a radio-style row where selecting one chip deselects the row's
/// others; by default chips toggle independently. `gridColumns` (2 or 3) lays
/// items out as a uniform grid instead of `FlowLayout`'s content-sized
/// wrapping — only for rows whose items are short, roughly-equal-length
/// phrases (e.g. a red-flag checklist). Most
/// rows must keep FlowLayout (nil): a fixed grid makes longer,
/// sentence-style chips (e.g. alternate-diagnosis chips) wrap raggedly,
/// which is why FlowLayout replaced grids app-wide in the first place (see
/// FlowLayout's own doc comment).
struct ChipRow: Decodable {
    let tag: String?
    let items: [ChipItem]
    let exclusive: Bool
    let gridColumns: Int?
    /// A reference `numeric_calc` tucked behind a small link next to this
    /// row's own tag (e.g. sep's "Vitals for age" → age-based threshold
    /// lookup) — collapsed by default, opened in the same `.sheet` a
    /// standalone `numeric_calc` card block uses, instead of a second
    /// always-visible top-level block for what's really just this row's own
    /// reference data. `linkLabel` is the sheet's title; falls back to `tag`
    /// if omitted.
    let linkCalcId: String?
    let linkLabel: String?

    init(tag: String? = nil, items: [ChipItem], exclusive: Bool = false, gridColumns: Int? = nil, linkCalcId: String? = nil, linkLabel: String? = nil) {
        self.tag = tag
        self.items = items
        self.exclusive = exclusive
        self.gridColumns = gridColumns
        self.linkCalcId = linkCalcId
        self.linkLabel = linkLabel
    }

    private enum CodingKeys: String, CodingKey { case tag, items, exclusive, gridColumns, linkCalcId = "link_calc_id", linkLabel = "link_label" }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tag = try container.decodeIfPresent(String.self, forKey: .tag)
        items = try container.decode([ChipItem].self, forKey: .items)
        exclusive = try container.decodeIfPresent(Bool.self, forKey: .exclusive) ?? false
        gridColumns = try container.decodeIfPresent(Int.self, forKey: .gridColumns)
        linkCalcId = try container.decodeIfPresent(String.self, forKey: .linkCalcId)
        linkLabel = try container.decodeIfPresent(String.self, forKey: .linkLabel)
    }
}

/// A fully-loaded calculator: its display rows plus the rule that turns
/// checked keys into a verdict. Referenced by a card's `chip_screen` block
/// via `calc_id`, e.g. `Content/Calculators/c_palf.json`.
struct ChipScreen: Decodable {
    let id: String
    let rows: [ChipRow]
    let rule: ChipRuleConfig

    static func load(calcId: String, bundle: Bundle = .main) -> ChipScreen? {
        guard let url = bundle.url(forResource: calcId, withExtension: "json", subdirectory: "Content/Calculators"),
              let data = try? Data(contentsOf: url),
              let screen = try? JSONDecoder().decode(ChipScreen.self, from: data)
        else { return nil }
        return screen
    }

    var verdictRule: VerdictRule {
        switch rule {
        case .checklistAny(let r): return r
        case .chipScore(let r): return r
        case .chipCount(let r): return r
        case .chipTier(let r): return r
        case .named(let ruleId):
            // Hand-written Swift rules for logic too irregular for the four
            // declarative kinds. Register each new one here by rule_id.
            switch ruleId {
            default:
                preconditionFailure("chip_screen '\(id)' references unknown named rule_id \"\(ruleId)\"")
            }
        }
    }
}

/// Discriminates the 4 declarative rule kinds plus "named" (a hardcoded Swift
/// VerdictRule, selected by `rule_id`, for logic too irregular to express
/// as a threshold table).
enum ChipRuleConfig: Decodable {
    case checklistAny(ChecklistAnyRule)
    case chipScore(ChipScoreRule)
    case chipCount(ChipCountRule)
    case chipTier(ChipTierRule)
    case named(String)

    private enum CodingKeys: String, CodingKey { case kind, ruleId = "rule_id" }
    private enum Kind: String, Decodable { case checklistAny = "checklist_any", chipScore = "chip_score", chipCount = "chip_count", chipTier = "chip_tier", named }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .checklistAny: self = .checklistAny(try ChecklistAnyRule(from: decoder))
        case .chipScore: self = .chipScore(try ChipScoreRule(from: decoder))
        case .chipCount: self = .chipCount(try ChipCountRule(from: decoder))
        case .chipTier: self = .chipTier(try ChipTierRule(from: decoder))
        case .named: self = .named(try container.decode(String.self, forKey: .ruleId))
        }
    }
}
