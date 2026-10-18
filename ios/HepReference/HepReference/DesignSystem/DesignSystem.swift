import SwiftUI

/// Named spacing scale — every view should use these instead of inventing its
/// own padding number (the audit found 6/8/9/10/11/12 all used ad hoc for
/// visually-equivalent gaps). See notes/ios_redesign_plan.md §Phase R0.
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

/// Shared grid layouts — `CardListView` and `SearchView` both lay out card
/// tiles two-up, and must use the exact same `GridItem` spacing so a search
/// result reads as the identical tile it is in Browse, not a slightly
/// different one.
enum GridLayout {
    /// For a `ChipRow`'s `gridColumns: 1` — every chip full-width and
    /// stacked, matching the width of the calculator's own verdict banner
    /// (e.g. kd's 5 long principal-feature items) instead of a flow that
    /// wraps ragged, content-sized chips.
    static let oneColumn = [GridItem(.flexible())]
    static let twoColumns = [
        GridItem(.flexible(), spacing: Spacing.s),
        GridItem(.flexible(), spacing: Spacing.s),
    ]
    /// For a `ChipRow`'s `gridColumns: 3` (currently just fyi's high-risk
    /// screen, 8 short items).
    static let threeColumns = [
        GridItem(.flexible(), spacing: Spacing.s),
        GridItem(.flexible(), spacing: Spacing.s),
        GridItem(.flexible(), spacing: Spacing.s),
    ]
}

/// Named text roles. SF Pro (system default) for everything except tags/codes,
/// which use SF Mono, plus one bundled accent font (`hepDisplay`) reserved for
/// a short list of "hero" moments — the hybrid typography decision made in
/// notes/ios_premium_pass_plan.md's Phase P1, superseding R0's original
/// SF-only lock. `hepDisplay` must never be used for dosing numbers,
/// calculator input/output values, or pathway node text — see that plan's
/// cross-cutting safety constraint.
extension Font {
    /// Space Grotesk (SIL OFL, bundled in Resources/Fonts) — app name/launch
    /// mark and a card's top-level title (`CardHeaderView`) only. Uses
    /// `relativeTo:` so it still scales with Dynamic Type like every other
    /// token here.
    static func hepDisplay(_ style: Font.TextStyle = .title2, weight: Font.Weight = .bold) -> Font {
        let postscriptName: String
        switch weight {
        case .bold, .heavy, .black: postscriptName = "SpaceGrotesk-Bold"
        case .medium, .semibold: postscriptName = "SpaceGrotesk-Medium"
        default: postscriptName = "SpaceGrotesk-Regular"
        }
        return .custom(postscriptName, size: style.hepDefaultPointSize, relativeTo: style)
    }

    /// Two sizes up from the original `.caption` and `.bold` (not
    /// `.semibold`) — these are now a collapsible section's own tappable
    /// header (see `CollapsibleSection`), not a passive label, so they carry
    /// more visual weight than the rest of the app's monospace kickers.
    static let hepSectionHeading: Font = .system(.subheadline, design: .monospaced).weight(.bold)
    static let hepBody: Font = .body
    /// Short badge/tag text (pathway arm tags, disposition pills, acuity
    /// badges) — always uppercase, always ≤2 lines. See `Badge`.
    static let hepTag: Font = .system(.caption2, design: .monospaced).weight(.semibold)
    /// Longer monospace body text — e.g. a pathway arm's `rx` action line.
    /// Distinct from `hepTag`: regular weight, one size up, not meant to be
    /// uppercased or badge-wrapped, since it's a sentence to read, not a label
    /// to scan.
    static let hepMono: Font = .system(.caption, design: .monospaced)
    /// A calculator's own name/title (`CalculatorHeader`) — same monospaced
    /// design language as `hepSectionHeading`/`hepTag` (so it reads as the
    /// same *kind* of text as a pathway or block section heading, fixing the
    /// calculator-vs-pathway font mismatch), one size up from
    /// `hepSectionHeading` so it doesn't collide with the "CALCULATOR" kicker
    /// directly above it, and not uppercased since it's an authored name.
    /// Bumped to `.body`/`.bold` alongside `hepSectionHeading` — most
    /// calculators now show this inside a `CollapsibleSection` header too.
    static let hepCalcTitle: Font = .system(.body, design: .monospaced).weight(.bold)
    /// The one shared "big result number" style for every calculator's
    /// headline answer (score total, dose total, probability %) — deliberately
    /// SF Pro, not `hepDisplay`: this is a value a clinician reads under
    /// pressure, not a branding moment.
    static let hepMetric: Font = .title2.weight(.bold).monospacedDigit()
    /// A chip row / score dimension's own label, above its options. Bumped
    /// from `.caption` (paired with `.secondary`, it read as too washed-out
    /// once a screen had several of these stacked back-to-back, e.g. cds's
    /// 5 scoring dimensions) to `.subheadline`/`.bold`, paired with
    /// `.primary` at both call sites (`ChipRowView`, `ScoreDimensionRow`).
    static let hepRowLabel: Font = .subheadline.weight(.bold)
    static let hepCaption: Font = .caption
    /// Small inline icon glyphs (e.g. an outcome row's "→" arrow) that were
    /// previously bare `.caption2` literals.
    static let hepIconSmall: Font = .caption2
    /// Medium inline icon glyphs (e.g. a verdict banner's band icon) that
    /// were previously bare `.subheadline.weight(.semibold)` literals.
    static let hepIconMedium: Font = .subheadline.weight(.semibold)
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

/// The 4 semantic severity/disposition tiers used throughout the app —
/// unifies what `AcuLevel`, `ArmKind`, and `PillKind` each mapped to colors
/// separately. Backed by the Assets.xcassets color sets (light+dark),
/// replacing runtime `.opacity()` math on system colors.
enum Tier {
    case crit, urg, rt, ref

    /// Strong fill — white text on top (tags, pills, solid badges).
    var solid: Color {
        switch self {
        case .crit: Color("critSolid")
        case .urg: Color("urgSolid")
        case .rt: Color("rtSolid")
        case .ref: Color("refSolid")
        }
    }

    /// Pale background tint — this tier's `solid` color as foreground on top.
    var tint: Color {
        switch self {
        case .crit: Color("critTint")
        case .urg: Color("urgTint")
        case .rt: Color("rtTint")
        case .ref: Color("refTint")
        }
    }
}
