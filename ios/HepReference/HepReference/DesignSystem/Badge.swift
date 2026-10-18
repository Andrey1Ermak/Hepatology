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
/// and pill `Text`s, and the numeric calculators' ad hoc "max" `Capsule`s
/// (migrated across Phases R2-R4, see notes/ios_redesign_plan.md). Unlike
/// those, this always wraps to up to 2 lines instead of letting a long tag
/// silently squeeze an HStack — the concrete fix for the condition/tag
/// text-wrap bug identified in the plan's Diagnosis §4.
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
    /// Extra emphasis on top of `hepTag`'s own semibold weight — for a
    /// `.neutral` cond badge that's really a sub-branch header inside an arm
    /// (e.g. axflow's "Age < 5 yr"/"Uncomplicated"), which otherwise reads
    /// at the same weight as every other plain outcome condition.
    var bold: Bool = false

    var body: some View {
        Text(uppercase ? text.uppercased() : text)
            .font(bold ? .hepTag.weight(.bold) : .hepTag)
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
        case .solid: tier?.solid ?? Color(.tertiarySystemFill)
        case .tint: tier?.tint ?? Color(.tertiarySystemFill)
        // `cardSurface`, not `tertiarySystemFill`: a `.neutral` badge (group
        // labels, outcome conditions) most often sits on `SectionCard`'s
        // tinted `blockTint` background now, where a plain system-gray fill
        // blended in rather than standing out as its own marker.
        case .neutral: Color("cardSurface")
        }
    }

    private var foreground: Color {
        switch style {
        case .solid: .white
        case .tint: tier?.solid ?? .secondary
        case .neutral: .secondary
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
