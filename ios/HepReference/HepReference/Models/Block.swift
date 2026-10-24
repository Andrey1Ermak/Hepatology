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
