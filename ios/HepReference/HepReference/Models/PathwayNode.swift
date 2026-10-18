import Foundation

/// Arm severity/disposition color, reusing the same 4-color semantics as
/// AcuLevel: mild≈rt, mod≈urg, sev≈crit, floor≈ref (see template.html's
/// `.asarm.*` CSS — floor is a 4th real kind beyond the plan's mild/mod/sev,
/// used for plain "admit to floor" arms).
enum ArmKind: String, Decodable {
    case mild, mod, sev, floor
}

/// Disposition pill color (`.aspill.*` in template.html).
enum PillKind: String, Decodable {
    case dc, step, floor, picu
}

/// Background tint for a boxed group of facts (`.asfacts.*` in template.html).
enum BoxStyle: String, Decodable {
    case plain, info, warn, crit
}

struct Pill: Decodable {
    let kind: PillKind
    let text: String
}

/// One node in a card's clinical pathway tree — a direct port of
/// template.html's `sec`/`arm`/`out`/`nest`/`grp`/`row`/`col`/`f` helper
/// functions (see notes/ios_plan.md §Phase 3). Recursive: most cases carry
/// `children: [PathwayNode]`.
indirect enum PathwayNode: Decodable {
    /// A titled section ("sec" — e.g. "Workup", "Treatment", "Follow-up").
    case section(heading: String, children: [PathwayNode])
    /// A colored fact box ("asfacts" wrapper) with no heading of its own.
    case box(style: BoxStyle, children: [PathwayNode])
    /// A small label followed by grouped content ("grp").
    case group(label: String, children: [PathwayNode])
    /// A colored decision arm: severity/disposition kind, a tag, an optional
    /// one-line prescription/action ("rx"), then nested content.
    case arm(kind: ArmKind, tag: String, rx: String?, children: [PathwayNode])
    /// An outcome row: an optional condition (omitted when the enclosing
    /// arm's own tag already states it, avoiding a redundant restatement),
    /// then either 1+ disposition pills (usually one; two side-by-side,
    /// "/"-separated, for a shared-decision either/or outcome — e.g. febpath's
    /// "CSF WBC < 19 - SDM" → Admit PHM / Home) or a plain subtext note
    /// (template.html's "out"/"step" — never pills and subtext together).
    /// A cond-only `out` (no pills, no subtext) also doubles as a flush
    /// section marker inside an arm — same shape `ChipRow` uses for its own
    /// `linkCalcId`/`linkLabel` — so a marker like axflow's "AGE ≥ 5 YR →
    /// RUN pARC" can carry a "Calculate" link to a reference `numeric_calc`
    /// instead of that calculator living in its own always-visible top-level
    /// block. `condBold` marks a cond that's really a sub-branch header
    /// inside an arm (e.g. axflow's "Age < 5 yr"/"Uncomplicated") — one step
    /// down from the arm's own tag, one step up from a plain outcome cond.
    case out(condition: String?, pills: [Pill], subtext: String?, linkCalcId: String?, linkLabel: String?, condBold: Bool)
    /// Indented nested content ("nest").
    case nest(children: [PathwayNode])
    /// A single fact line: optional bold label ("f") or plain text ("row").
    /// `bullet` is `true` unless a row explicitly opts out — a lone
    /// standalone fact (e.g. a one-row warning box) can read as an
    /// unexplained list of one rather than a callout. `linkCalcId`/`linkLabel`
    /// put a trailing "Calculate" button on the same bulleted line (e.g.
    /// brue's "Assess NAT risk" → PIBIS) — for a plain bullet that needs a
    /// calculator link but shouldn't be promoted into an `out`'s boxed
    /// condition badge.
    case row(label: String?, text: String, bullet: Bool, linkCalcId: String?, linkLabel: String?)
    /// A column grouping ("col") — visual grouping, not a layout column.
    case col(children: [PathwayNode])
    /// A reference table — reuses Phase 1's TableBlockView.
    case table(head: [String], rows: [[String]])

    private enum CodingKeys: String, CodingKey {
        case t, h, style, label, kind, tag, rx, cond, pill, pills, subtext, text, bullet, head, rows, children
        case linkCalcId = "link_calc_id", linkLabel = "link_label", condBold = "cond_bold"
    }

    private enum Kind: String, Decodable {
        case section, box, group, arm, out, nest, row, col, table
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        func children() throws -> [PathwayNode] {
            try c.decodeIfPresent([PathwayNode].self, forKey: .children) ?? []
        }
        switch try c.decode(Kind.self, forKey: .t) {
        case .section:
            self = .section(heading: try c.decode(String.self, forKey: .h), children: try children())
        case .box:
            self = .box(style: try c.decode(BoxStyle.self, forKey: .style), children: try children())
        case .group:
            self = .group(label: try c.decode(String.self, forKey: .label), children: try children())
        case .arm:
            self = .arm(
                kind: try c.decode(ArmKind.self, forKey: .kind),
                tag: try c.decode(String.self, forKey: .tag),
                rx: try c.decodeIfPresent(String.self, forKey: .rx),
                children: try children()
            )
        case .out:
            let pills: [Pill]
            if let multiple = try c.decodeIfPresent([Pill].self, forKey: .pills) {
                pills = multiple
            } else if let single = try c.decodeIfPresent(Pill.self, forKey: .pill) {
                pills = [single]
            } else {
                pills = []
            }
            self = .out(
                condition: try c.decodeIfPresent(String.self, forKey: .cond),
                pills: pills,
                subtext: try c.decodeIfPresent(String.self, forKey: .subtext),
                linkCalcId: try c.decodeIfPresent(String.self, forKey: .linkCalcId),
                linkLabel: try c.decodeIfPresent(String.self, forKey: .linkLabel),
                condBold: try c.decodeIfPresent(Bool.self, forKey: .condBold) ?? false
            )
        case .nest:
            self = .nest(children: try children())
        case .row:
            self = .row(
                label: try c.decodeIfPresent(String.self, forKey: .label),
                text: try c.decode(String.self, forKey: .text),
                bullet: try c.decodeIfPresent(Bool.self, forKey: .bullet) ?? true,
                linkCalcId: try c.decodeIfPresent(String.self, forKey: .linkCalcId),
                linkLabel: try c.decodeIfPresent(String.self, forKey: .linkLabel)
            )
        case .col:
            self = .col(children: try children())
        case .table:
            self = .table(head: try c.decode([String].self, forKey: .head), rows: try c.decode([[String]].self, forKey: .rows))
        }
    }
}

/// A card's full pathway tree, referenced by a `pathway` block via `path_id`,
/// e.g. `Content/Pathways/iihpath.json`. The source app's left/right 2-column
/// layout is flattened into one ordered list — iOS reads pathways as a single
/// vertical scroll (see notes/ios_plan.md's "on iOS the natural flow is vertical").
struct Pathway: Decodable {
    let id: String
    let children: [PathwayNode]

    static func load(pathId: String, bundle: Bundle = .main) -> Pathway? {
        guard let url = bundle.url(forResource: pathId, withExtension: "json", subdirectory: "Content/Pathways"),
              let data = try? Data(contentsOf: url),
              let pathway = try? JSONDecoder().decode(Pathway.self, from: data)
        else { return nil }
        return pathway
    }
}
