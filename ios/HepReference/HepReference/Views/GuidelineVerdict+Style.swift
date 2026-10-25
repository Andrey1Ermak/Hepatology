import SwiftUI

extension GuidelineVerdict {
    /// Tag text, as in the lessons' comparison tables.
    var label: String {
        switch self {
        case .aligned: "ALIGNED"
        case .differs: "DIFFERS"
        case .material: "MATERIAL"
        case .gap: "GAP"
        }
    }

    /// Solid cell fill — CLAUDE.md §12.2: ALIGNED ok, DIFFERS urg,
    /// MATERIAL crit, GAP gap.
    var fill: Color {
        switch self {
        case .aligned: Tier.rt.solid
        case .differs: Tier.urg.solid
        case .material: Tier.crit.solid
        case .gap: Color.hepGap
        }
    }

    /// Text on `fill`: dark on the bright urg and gap fills (D-2026-10-18-4).
    var onFill: Color {
        switch self {
        case .aligned: Tier.rt.onSolid
        case .differs: Tier.urg.onSolid
        case .material: Tier.crit.onSolid
        case .gap: Color.hepOnBright
        }
    }

    /// What VoiceOver reads for the tag.
    var accessibilityLabel: String { "Verdict: \(accessibilityDescription)" }

    /// Spoken meaning, so VoiceOver users get more than the tag word.
    var accessibilityDescription: String {
        switch self {
        case .aligned: "aligned"
        case .differs: "differs"
        case .material: "material difference, changes management"
        case .gap: "gap, no guideline"
        }
    }
}

/// The verdict cell of a `guideline_compare` row (CLAUDE.md §12.3): solid
/// fill in the verdict's color, `hepTag` centered.
struct GuidelineVerdictTag: View {
    let verdict: GuidelineVerdict
    /// Keeps the four tags one width at the default text size; scales
    /// with Dynamic Type.
    @ScaledMetric(relativeTo: .caption2) private var minWidth: CGFloat = 76

    var body: some View {
        Text(verdict.label)
            .font(.hepTag)
            .foregroundStyle(verdict.onFill)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.xs)
            .fixedSize()
            .frame(minWidth: minWidth)
            .background(verdict.fill)
            .clipShape(RoundedRectangle(cornerRadius: Radius.small))
            .accessibilityLabel(verdict.accessibilityLabel)
    }
}
