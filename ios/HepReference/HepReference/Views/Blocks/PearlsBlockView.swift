import SwiftUI

/// Pearls & pitfalls (CLAUDE.md §3.3 row 7) — a Learn-layer section,
/// collapsed until tapped. Each line is marked by kind: a navy lightbulb
/// tile for a pearl, an amber warning tile for a pitfall. Glyphs sit on a
/// solid fill so they keep contrast in both themes.
struct PearlsBlockView: View {
    let block: PearlsBlock
    /// Open on appear — the DEBUG design sample only.
    var startsExpanded = false
    /// Side of the kind marker; scales with Dynamic Type like its glyph.
    @ScaledMetric(relativeTo: .caption2) private var tile: CGFloat = 22

    var body: some View {
        CollapsibleSection(title: block.h ?? "Pearls & pitfalls", startsExpanded: startsExpanded) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                ForEach(Array(block.items.enumerated()), id: \.offset) { _, item in
                    row(item)
                }
            }
        }
    }

    private func row(_ item: PearlItem) -> some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            Image(systemName: item.k.symbol)
                .font(.hepIconSmall)
                .foregroundStyle(item.k.tier.onSolid)
                .frame(width: tile, height: tile)
                .background(item.k.tier.solid)
                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                .accessibilityHidden(true)
            Text(CardMarkup.attributedString(item.text))
                .font(.hepBody)
                .foregroundStyle(Color.hepInk)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.k.spokenName): \(CardMarkup.plainText(item.text))")
    }
}

extension PearlKind {
    var symbol: String {
        switch self {
        case .pearl: "lightbulb.fill"
        case .pitfall: "exclamationmark.triangle.fill"
        }
    }

    var tier: Tier {
        switch self {
        case .pearl: .ref
        case .pitfall: .urg
        }
    }

    var spokenName: String {
        switch self {
        case .pearl: "Pearl"
        case .pitfall: "Pitfall"
        }
    }
}
