import SwiftUI

enum BadgeStyle {
    /// Colored fill, white text — for tags/pills that must pop (pathway arm
    /// tags, disposition pills).
    case solid
    /// Pale tinted fill, colored text — for softer inline markers (acuity badge).
    case tint
    /// Neutral gray marker not tied to a severity tier — e.g. a pathway
    /// outcome row's condition label, which is the finding as authored, not
    /// a severity indicator (see OutView).
    case neutral
}

/// The one badge component for every colored tag/pill/acuity-marker in the
/// app — replaces `AcuBadge`, `ArmView`'s tag `Text`, `OutView`'s condition
/// and pill `Text`s, and the numeric calculators' ad hoc "max" `Capsule`s.
/// Unlike those, this always wraps to up to 2 lines instead of letting a long tag
/// silently squeeze an HStack — the fix for condition/tag text wrapping.
struct Badge: View {
    let text: String
    var tier: Tier? = nil
    var style: BadgeStyle = .solid
    /// `.neutral` badges (condition labels) are the finding as authored —
    /// forcing uppercase there can lose meaning, unlike a severity tag.
    var uppercase: Bool = true
    /// `nil` disables the cap entirely — for a long arm tag paired with an
    /// inline pill (see `ArmView`), where 2 lines silently truncated real
    /// clinical criteria instead of just wrapping.
    var maxLines: Int? = 2
    /// Stretches to the height of a taller HStack sibling instead of
    /// hugging its own content — for a pill placed inline next to a
    /// multi-line arm tag (see `ArmView`), so the two read as the same
    /// height instead of a short pill floating beside a tall tag.
    var fillHeight: Bool = false
    /// Extra emphasis on top of `hepTag`'s own bold weight — for a
    /// `.neutral` cond badge that's really a sub-branch header inside an arm
    /// (e.g. "Age < 1 yr"/"Uncomplicated"), which otherwise reads
    /// at the same weight as every other plain outcome condition.
    var bold: Bool = false

    var body: some View {
        Text(uppercase ? text.uppercased() : text)
            .font(bold ? .hepTagHeavy : .hepTag)
            .tracking(0.4)
            .lineLimit(maxLines)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            // 6, not `Spacing.s` (8): a solid rounded-pill fill reads as
            // starting further right than a bare bullet dot even at an
            // identical x-coordinate (RowView's dot+gap is also 8pt to its
            // text) — a bare dot has far less visual mass than a filled
            // pill, so the pill needs a tighter inset to *look* level with
            // a sibling bulleted row at the same leading edge (e.g. a
            // `col`'s "General"/"IV fluids" labels above their bullet lists).
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .frame(maxHeight: fillHeight ? .infinity : nil)
            .foregroundStyle(foreground)
            .background(background, in: RoundedRectangle(cornerRadius: Radius.small))
    }

    private var background: Color {
        switch style {
        case .solid: tier?.solid ?? Color.hepGap
        case .tint: tier?.tint ?? Color.hepSurface
        // `hepCard`, not `hepSurface`: a `.neutral` badge (group labels,
        // outcome conditions) most often sits on `SectionCard`'s `hepSurface`
        // background, where the same gray would blend in instead of reading
        // as its own marker.
        case .neutral: Color.hepCard
        }
    }

    private var foreground: Color {
        switch style {
        case .solid: tier?.onSolid ?? Color.hepOnBright
        // Ink, not the tier's own solid color: amber and green text on their
        // own pale tints fall below 4.5:1 (CLAUDE.md §12.4).
        case .tint: Color.hepInk
        case .neutral: Color.hepMuted
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        HStack { Badge(text: "Crit", tier: .crit); Badge(text: "Urg", tier: .urg); Badge(text: "RT", tier: .rt); Badge(text: "Ref", tier: .ref) }
        HStack { Badge(text: "Crit", tier: .crit, style: .tint); Badge(text: "Urg", tier: .urg, style: .tint) }
        Badge(text: "GCS 14", style: .neutral, uppercase: false)
        Badge(text: "Poor/no response to racemic epinephrine — consider bacterial tracheitis", tier: .urg)
            .frame(width: 160)
    }
    .padding()
}
