import SwiftUI

/// A colored decision arm (severity or disposition), matching template.html's
/// `.asarm` — a tinted SectionCard with a leading accent bar, a severity tag
/// badge, an optional monospace "rx" action line, then nested content.
///
/// When the arm's very first child is a bare disposition pill or pills (an
/// `.out` with no condition/subtext of its own — the condition would just
/// restate `tag`, e.g. hb2col's arms), it renders inline next to the tag
/// instead of as its own row below: "tag → pill" (or "tag → pill / pill" for
/// a shared-decision either/or outcome) reads as one symmetric header
/// instead of a big tag banner followed by a disconnected pill. Every other
/// arm (whose first child carries real content) is unaffected.
struct ArmView: View {
    let kind: ArmKind
    let tag: String
    let rx: String?
    let children: [PathwayNode]

    private var inlinePills: [Pill] {
        guard let first = children.first, case .out(nil, let pills, nil, nil, nil, _) = first, !pills.isEmpty else { return [] }
        return pills
    }

    private var remainingChildren: [PathwayNode] {
        inlinePills.isEmpty ? children : Array(children.dropFirst())
    }

    var body: some View {
        SectionCard(background: kind.tier.tint, accent: kind.tier.solid) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                HStack(alignment: .center, spacing: Spacing.s) {
                    // `maxLines: nil` — a tag must never silently truncate
                    // real clinical criteria just because a pill now sits
                    // beside it and narrowed the available width.
                    Badge(text: tag, tier: kind.tier, maxLines: nil)
                        .frame(maxWidth: inlinePills.isEmpty ? nil : .infinity, alignment: .leading)
                    if !inlinePills.isEmpty {
                        DispositionArrow()
                        ForEach(Array(inlinePills.enumerated()), id: \.offset) { index, pill in
                            if index > 0 {
                                Text("/")
                                    .font(.hepCaption)
                                    .foregroundStyle(.secondary)
                            }
                            // `fillHeight: true` — matches the tag's height
                            // (however many lines it wraps to) instead of
                            // staying pill-sized next to a taller tag.
                            // `maxLines: nil` — a folded-in pill (e.g. "Admit
                            // PHM · Ampicillin + Cefepime + Acyclovir") must
                            // wrap, not truncate, same reasoning as the tag.
                            Badge(text: pill.text, tier: pill.kind.tier, maxLines: nil, fillHeight: true)
                        }
                    }
                }
                if let rx {
                    Text(CardMarkup.attributedString(rx))
                        .font(.hepMono)
                        .foregroundStyle(.secondary)
                }
                BranchedChildrenView(children: remainingChildren)
            }
            .environment(\.pathwayAccent, kind.tier.solid)
        }
    }
}
