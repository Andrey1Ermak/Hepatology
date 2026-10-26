import Foundation

/// One of the unified block types (7 standard + custom ones that point at
/// calculators, pathways or registries).
/// Discriminated by the `t` key; each case decodes its own flat payload from the
/// same container (extra sibling keys, like `t` itself, are ignored by Codable).
enum Block: Decodable {
    case note(NoteBlock)
    case list(ListBlock)
    case dose(DoseBlock)
    case branch(BranchBlock)
    case kv(KVBlock)
    case table(TableBlock)
    case text(TextBlock)
    case chipScreen(ChipScreenBlock)
    case pathway(PathwayBlock)
    case scoreCalc(ScoreCalcBlock)
    case numericCalc(NumericCalcBlock)
    case ageSwitch(AgeSwitchBlock)
    case workup(WorkupBlock)
    case labNorms(LabNormsBlock)
    case pearls(PearlsBlock)
    case guidelineCompare(GuidelineCompareBlock)
    case cases(CaseBlock)

    private enum CodingKeys: String, CodingKey {
        case type = "t"
    }

    private enum BlockType: String, Decodable {
        case note, list, dose, branch, kv, table, text
        case chipScreen = "chip_screen"
        case pathway
        case scoreCalc = "score_calc"
        case numericCalc = "numeric_calc"
        case ageSwitch = "age_switch"
        case workup
        case labNorms = "lab_norms"
        case pearls
        case guidelineCompare = "guideline_compare"
        case cases = "case"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(BlockType.self, forKey: .type) {
        case .note: self = .note(try NoteBlock(from: decoder))
        case .list: self = .list(try ListBlock(from: decoder))
        case .dose: self = .dose(try DoseBlock(from: decoder))
        case .branch: self = .branch(try BranchBlock(from: decoder))
        case .kv: self = .kv(try KVBlock(from: decoder))
        case .table: self = .table(try TableBlock(from: decoder))
        case .text: self = .text(try TextBlock(from: decoder))
        case .chipScreen: self = .chipScreen(try ChipScreenBlock(from: decoder))
        case .pathway: self = .pathway(try PathwayBlock(from: decoder))
        case .scoreCalc: self = .scoreCalc(try ScoreCalcBlock(from: decoder))
        case .numericCalc: self = .numericCalc(try NumericCalcBlock(from: decoder))
        case .ageSwitch: self = .ageSwitch(try AgeSwitchBlock(from: decoder))
        case .workup: self = .workup(try WorkupBlock(from: decoder))
        case .labNorms: self = .labNorms(try LabNormsBlock(from: decoder))
        case .pearls: self = .pearls(try PearlsBlock(from: decoder))
        case .guidelineCompare: self = .guidelineCompare(try GuidelineCompareBlock(from: decoder))
        case .cases: self = .cases(try CaseBlock(from: decoder))
        }
    }
}

// MARK: - Standard blocks

enum NoteLevel: String, Decodable {
    case crit, warn, info
}

struct NoteBlock: Decodable {
    let h: String?
    let k: NoteLevel
    let text: String
}

/// A list item is either a plain bullet string, or `{t: title, sub: [String]}`
/// (e.g. adol_consent's "Minor consent by service" list).
enum ListItem: Decodable {
    case plain(String)
    case titled(title: String, sub: [String])

    private struct Titled: Decodable {
        let t: String
        let sub: [String]
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let plain = try? container.decode(String.self) {
            self = .plain(plain)
            return
        }
        let titled = try Titled(from: decoder)
        self = .titled(title: titled.t, sub: titled.sub)
    }
}

struct ListBlock: Decodable {
    let h: String?
    let items: [ListItem]
}

struct DoseItem: Decodable {
    let d: String
    let x: [String]
    let n: String?
}

struct DoseBlock: Decodable {
    let h: String?
    let items: [DoseItem]
}

struct BranchOption: Decodable {
    let `if`: String
    let then: String
}

struct BranchBlock: Decodable {
    let h: String?
    let opts: [BranchOption]
}

/// A `[key, value]` pair, e.g. `["Trauma", "[m]864-9439[/m]"]`.
struct KVRow: Decodable {
    let key: String
    let value: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        key = try container.decode(String.self)
        value = try container.decode(String.self)
    }
}

struct KVBlock: Decodable {
    let h: String?
    let rows: [KVRow]
}

struct TableBlock: Decodable {
    let h: String?
    let head: [String]
    let rows: [[String]]
}

struct TextBlock: Decodable {
    let h: String?
    let text: String
}

// MARK: - Custom blocks (identify a calculator/pathway by id; the referenced
// content lives in Content/Calculators and is implemented in later phases).

struct ChipScreenBlock: Decodable {
    let h: String?
    let calcId: String
    let label: String?

    enum CodingKeys: String, CodingKey {
        case h, label
        case calcId = "calc_id"
    }
}

struct PathwayBlock: Decodable {
    let h: String?
    let pathId: String

    enum CodingKeys: String, CodingKey {
        case h
        case pathId = "path_id"
    }
}

struct ScoreCalcBlock: Decodable {
    let h: String?
    let calcId: String
    let label: String?

    enum CodingKeys: String, CodingKey {
        case h, label
        case calcId = "calc_id"
    }
}

struct NumericCalcBlock: Decodable {
    let h: String?
    let calcId: String
    let label: String?

    enum CodingKeys: String, CodingKey {
        case h, label
        case calcId = "calc_id"
    }
}

/// One age branch of an `age_switch`: the chip label and the pathway shown
/// while it is selected.
struct AgeSwitchOption: Decodable {
    let age: AgeBand
    let label: String
    let pathId: String

    enum CodingKeys: String, CodingKey {
        case age, label
        case pathId = "path_id"
    }
}

/// Age chips over a card's algorithm (CLAUDE.md §5.2): the selected
/// option's pathway renders beneath them.
struct AgeSwitchBlock: Decodable {
    let h: String?
    let options: [AgeSwitchOption]

    /// The option for `age`, or the first one when nothing is chosen yet
    /// (or the chosen age has no branch here). Nil only for an empty switch,
    /// which the integrity gate forbids.
    func option(for age: AgeBand?) -> AgeSwitchOption? {
        options.first { $0.age == age } ?? options.first
    }
}

/// One labeled group of first-contact orders, e.g. "Blood — today".
struct WorkupGroup: Decodable {
    let label: String
    let items: [String]
}

/// Position of one order inside a `WorkupBlock`: group index, item index.
struct WorkupItemID: Hashable {
    let group: Int
    let item: Int
}

/// The card's first-contact orders (CLAUDE.md §3.3 row 4, §5.2): groups of
/// items the fellow can tick and copy as plain text.
struct WorkupBlock: Decodable {
    let h: String?
    let groups: [WorkupGroup]

    /// Plain text for the clipboard: each group label on its own line, its
    /// items beneath as "- " lines, groups separated by a blank line. Copies
    /// only the ticked items (groups with none ticked are left out), or every
    /// item when nothing is ticked. Markup is stripped to readable text.
    func copyText(checked: Set<WorkupItemID> = []) -> String {
        groups.enumerated().compactMap { g, group -> String? in
            let lines = group.items.enumerated()
                .filter { i, _ in checked.isEmpty || checked.contains(WorkupItemID(group: g, item: i)) }
                .map { _, item in "- " + CardMarkup.plainText(item) }
            guard !lines.isEmpty else { return nil }
            return ([group.label] + lines).joined(separator: "\n")
        }
        .joined(separator: "\n\n")
    }
}

/// Reference limits for the listed analytes (CLAUDE.md §5.2). The numbers
/// live only in `Registry/labs.json`; the block names which analytes to show.
struct LabNormsBlock: Decodable {
    let h: String?
    /// Ids into `labs.json`, in display order.
    let analytes: [String]

    /// The listed analytes found in `labs`, in the block's order. An id
    /// missing from the registry is skipped here; the integrity gate fails
    /// on it before release.
    func labTests(in labs: [LabTest]) -> [LabTest] {
        analytes.compactMap { id in labs.first { $0.id == id } }
    }
}

enum PearlKind: String, Decodable {
    case pearl, pitfall
}

/// One teaching line: a pearl to carry, or a pitfall to avoid.
struct PearlItem: Decodable {
    let k: PearlKind
    let text: String
}

/// Pearls & pitfalls (CLAUDE.md §3.3 row 7, §5.2) — Learn layer.
struct PearlsBlock: Decodable {
    let h: String?
    let items: [PearlItem]
}

/// How the cited documents relate on one topic (CLAUDE.md §5.2, §12.2):
/// `material` changes management, `gap` means no guideline covers it.
enum GuidelineVerdict: String, Decodable, CaseIterable {
    case aligned, differs, material, gap
}

/// One document's position on a `guideline_compare` topic.
struct GuidelinePosition {
    /// Id into `guidelines.json`.
    let guidelineId: String
    let text: String
}

/// One topic of a `guideline_compare`: each document's position, keyed by
/// guideline id, and the team's verdict.
struct GuidelineCompareRow: Decodable {
    let topic: String
    let positions: [String: String]
    let verdict: GuidelineVerdict
    /// Why the difference matters clinically.
    let note: String?

    /// Positions oldest document first, as the lessons' comparison tables
    /// read (JSON object order is not preserved by decoding): by year, then
    /// by order in `guidelines.json`; ids missing from the registry go last
    /// by id (the integrity gate forbids them in shipped content).
    func orderedPositions(in guidelines: [Guideline]) -> [GuidelinePosition] {
        let index = Dictionary(guidelines.enumerated().map { ($1.id, ($1.year, $0)) }, uniquingKeysWith: { first, _ in first })
        return positions
            .sorted { a, b in
                switch (index[a.key], index[b.key]) {
                case let (x?, y?): x.0 != y.0 ? x.0 < y.0 : x.1 < y.1
                case (_?, nil): true
                case (nil, _?): false
                case (nil, nil): a.key < b.key
                }
            }
            .map { GuidelinePosition(guidelineId: $0.key, text: $0.value) }
    }
}

/// Where the guidelines agree and differ (CLAUDE.md §3.3 row 8, §5.2) —
/// Learn layer. Society names and years come from `guidelines.json`.
struct GuidelineCompareBlock: Decodable {
    let h: String?
    let rows: [GuidelineCompareRow]
}

/// "Test yourself" (CLAUDE.md §3.3 row 9, §5.2) — Learn layer. The cases
/// live only in `Registry/cases.json`; the block names which to show.
struct CaseBlock: Decodable {
    let h: String?
    /// Ids into `cases.json`, in display order.
    let caseIds: [String]

    enum CodingKeys: String, CodingKey {
        case h
        case caseIds = "case_ids"
    }

    /// The listed cases found in `cases`, in the block's order. An id
    /// missing from the registry is skipped here; the integrity gate fails
    /// on it before release.
    func clinicalCases(in cases: [ClinicalCase]) -> [ClinicalCase] {
        caseIds.compactMap { id in cases.first { $0.id == id } }
    }
}
