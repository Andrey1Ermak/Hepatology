import Foundation

/// One of the 11 unified block types (7 standard + 4 custom).
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

    private enum CodingKeys: String, CodingKey {
        case type = "t"
    }

    private enum BlockType: String, Decodable {
        case note, list, dose, branch, kv, table, text
        case chipScreen = "chip_screen"
        case pathway
        case scoreCalc = "score_calc"
        case numericCalc = "numeric_calc"
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
