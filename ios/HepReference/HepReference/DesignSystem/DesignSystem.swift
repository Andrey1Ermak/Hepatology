import SwiftUI

/// Named spacing scale — every view should use these instead of inventing its
/// own padding number (the audit found 6/8/9/10/11/12 all used ad hoc for
/// visually-equivalent gaps).
enum Spacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
}

/// Named corner-radius scale, replacing ad hoc 5/6/8/9/10 values per file.
enum Radius {
    static let small: CGFloat = 6
    static let medium: CGFloat = 9
    static let large: CGFloat = 12
}

/// Shared grid layouts — `CategoryView` and `SearchView` both lay out card
/// tiles two-up, and must use the exact same `GridItem` spacing so a search
/// result reads as the identical tile it is in a category, not a slightly
/// different one.
enum GridLayout {
    /// For a `ChipRow`'s `gridColumns: 1` — every chip full-width and
    /// stacked, matching the width of the calculator's own verdict banner
    /// (e.g. five long criterion items) instead of a flow that
    /// wraps ragged, content-sized chips.
    static let oneColumn = [GridItem(.flexible())]
    static let twoColumns = [
        GridItem(.flexible(), spacing: Spacing.s),
        GridItem(.flexible(), spacing: Spacing.s),
    ]
    /// For a `ChipRow`'s `gridColumns: 3` (for a screen of
    /// about eight short items).
    static let threeColumns = [
        GridItem(.flexible(), spacing: Spacing.s),
        GridItem(.flexible(), spacing: Spacing.s),
        GridItem(.flexible(), spacing: Spacing.s),
    ]
}

/// Named text roles — CLAUDE.md §12.1. Avenir Next (built into iOS, no
/// bundled font) in every role, the closest licensable match to the Abadi
/// face of the author's lesson decks. Every role goes through
/// `Font.custom(_:size:relativeTo:)`, so it scales with Dynamic Type exactly
/// like the matching system text style. Caps and tracking are view-level, not
/// font-level — see `hepTitleStyle()` / `hepKickerStyle()` below.
extension Font {
    /// Card and screen titles — Heavy, set in caps by `hepTitleStyle()`.
    static let hepTitle: Font = avenir(.heavy, .title3)
    /// Small caps line above a title (category / section). See `hepKickerStyle()`.
    static let hepKicker: Font = avenir(.bold, .caption)
    /// Source line under a title, captions under a figure.
    static let hepSubtitle: Font = avenir(.italic, .footnote)
    /// Heading of a block / section card.
    static let hepSectionHeading: Font = avenir(.bold, .subheadline)
    static let hepBody: Font = avenir(.regular, .body)
    /// `hepBody` one step heavier — a titled list item's own title.
    static let hepBodyEmphasis: Font = avenir(.demiBold, .body)
    /// A block's one-line take-home, as in the lessons' closing line.
    static let hepTakeaway: Font = avenir(.boldItalic, .subheadline)
    /// Sources at the foot of a block (pair with `Color.hepMuted`).
    static let hepCitation: Font = avenir(.italic, .caption2)
    /// Numbers that are read under pressure: thresholds, doses, calculator
    /// results. Bold with fixed-width digits so columns of values line up.
    static let hepMetric: Font = avenir(.bold, .title2).monospacedDigit()
    /// Badges, verdicts, pills — always uppercase, always ≤2 lines. See `Badge`.
    static let hepTag: Font = avenir(.bold, .caption2)
    /// `hepTag` one step heavier — a badge that heads a sub-branch.
    static let hepTagHeavy: Font = avenir(.heavy, .caption2)
    /// A chip row / score dimension's own label, above its options.
    static let hepRowLabel: Font = avenir(.bold, .subheadline)
    static let hepCaption: Font = avenir(.regular, .caption)
    /// `hepCaption` in Bold — a table's first (row-label) column.
    static let hepCaptionBold: Font = avenir(.bold, .caption)
    /// Small inline icon glyphs (e.g. an outcome row's "→" arrow).
    static let hepIconSmall: Font = .caption2
    /// Medium inline icon glyphs (e.g. a verdict banner's band icon).
    static let hepIconMedium: Font = .subheadline.weight(.semibold)

    /// The Avenir Next faces the roles above draw on. Raw values are
    /// PostScript names — `DesignSystemTests` checks every one is installed.
    enum AvenirFace: String, CaseIterable {
        case regular = "AvenirNext-Regular"
        case italic = "AvenirNext-Italic"
        case demiBold = "AvenirNext-DemiBold"
        case bold = "AvenirNext-Bold"
        case boldItalic = "AvenirNext-BoldItalic"
        case heavy = "AvenirNext-Heavy"
    }

    static func avenir(_ face: AvenirFace, _ style: Font.TextStyle) -> Font {
        .custom(face.rawValue, size: style.hepDefaultPointSize, relativeTo: style)
    }
}

extension View {
    /// Title treatment from the lessons: Heavy, caps, +0.5 tracking, navy.
    func hepTitleStyle() -> some View {
        font(.hepTitle).tracking(0.5).textCase(.uppercase).foregroundStyle(Color.hepNavy)
    }

    /// Kicker treatment: small Bold caps, +1 tracking, secondary blue.
    func hepKickerStyle() -> some View {
        font(.hepKicker).tracking(1).textCase(.uppercase).foregroundStyle(Color.hepBlue)
    }
}

/// Color tokens — CLAUDE.md §12.2. Each is an Assets.xcassets color set with
/// a light and a dark value; views use these names, never a literal color.
extension Color {
    static let hepInk = Color("ink")
    /// Brand navy — asset name kept as `brandAccent` because the project's
    /// global accent color setting points at it.
    static let hepNavy = Color("brandAccent")
    static let hepBlue = Color("blue")
    static let hepMaroon = Color("maroon")
    static let hepMuted = Color("muted")
    static let hepSurface = Color("surface")
    static let hepBackground = Color("appBackground")
    /// Raised card on the page background (card-list tiles, the search field).
    static let hepCard = Color("card")
    static let hepGap = Color("gap")
    /// Text on a saturated fill (`Tier.solid`, navy, maroon): white in light
    /// mode, near-black in dark mode, where the fills are light pastels.
    static let hepOnSolid = Color("onSolid")
    /// Text on the two light-mode fills too bright for white text at small
    /// sizes (`urg` amber, `gap` gray — both ~3:1 with white).
    static let hepOnBright = Color("onBright")
    /// Hairlines: input outlines, pathway tree connectors outside an arm.
    static let hepRule = Color("rule")
    /// Dimming layer behind a modal calculator sheet (alpha is in the asset).
    static let hepScrim = Color("scrim")
    /// Base color of `hepElevated()` shadows; the layer opacities live there.
    static let hepShadow = Color("shadow")
}

private extension Font.TextStyle {
    /// Default point size at the base (unscaled) Dynamic Type category —
    /// used as `Font.custom(_:size:relativeTo:)`'s `size:` argument so a
    /// custom font scales proportionally the same way the matching system
    /// text style would. SwiftUI doesn't expose this table, so it's
    /// hand-mirrored from Apple HIG's default Dynamic Type point sizes.
    var hepDefaultPointSize: CGFloat {
        switch self {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline, .body: 17
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        default: 17
        }
    }
}

/// The 4 semantic severity tiers used throughout the app — `AcuLevel`,
/// `ArmKind`, `PillKind` and `BoxStyle` all map onto these. Mapping to the
/// §12.2 tokens: crit→crit, urg→urg, rt→ok, ref→info.
enum Tier {
    case crit, urg, rt, ref

    /// Strong fill (tags, pills, solid badges, top stripes) — text on it uses `onSolid`.
    var solid: Color {
        switch self {
        case .crit: Color("crit")
        case .urg: Color("urg")
        case .rt: Color("ok")
        case .ref: Color("info")
        }
    }

    /// Text color on `solid` that keeps ≥ 4.5:1 contrast in both themes.
    var onSolid: Color {
        self == .urg ? .hepOnBright : .hepOnSolid
    }

    /// Pale background tint — this tier's `solid` color as foreground on top.
    var tint: Color {
        switch self {
        case .crit: Color("critTint")
        case .urg: Color("urgTint")
        case .rt: Color("okTint")
        case .ref: Color("infoTint")
        }
    }
}
