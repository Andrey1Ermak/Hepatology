import SwiftUI

/// Where the guidelines agree and differ (CLAUDE.md §3.3 row 8, §5.2) — a
/// Learn-layer section, collapsed until tapped. Each topic is a zebra row:
/// the topic in bold with its verdict cell (§12.3) beside it, then each
/// document's position under its society and year from `guidelines.json`,
/// then the clinical note. Full citations sit under a thin rule.
struct GuidelineCompareBlockView: View {
    let block: GuidelineCompareBlock
    /// Injected by previews and the design sample; nil reads the app's registry.
    var guidelines: [Guideline]?
    /// Open on appear — the DEBUG design sample only.
    var startsExpanded = false

    @Environment(Registry.self) private var registry: Registry?

    private var registryGuidelines: [Guideline] { guidelines ?? registry?.guidelines ?? [] }

    private var byID: [String: Guideline] {
        Dictionary(registryGuidelines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    var body: some View {
        CollapsibleSection(title: block.h ?? "Guidelines", startsExpanded: startsExpanded) {
            VStack(alignment: .leading, spacing: Spacing.m) {
                VStack(spacing: 0) {
                    ForEach(Array(block.rows.enumerated()), id: \.offset) { index, row in
                        rowView(row)
                            .padding(Spacing.s)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(index.isMultiple(of: 2) ? Color.hepBackground : Color.hepSurface)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                CitationFooter(citations: citations)
            }
        }
    }

    private func rowView(_ row: GuidelineCompareRow) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(alignment: .top, spacing: Spacing.s) {
                Text(CardMarkup.attributedString(row.topic))
                    .font(.hepBodyEmphasis)
                    .foregroundStyle(Color.hepInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
                GuidelineVerdictTag(verdict: row.verdict)
            }
            // Topic and verdict are spoken together, as the row's heading.
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            ForEach(row.orderedPositions(in: registryGuidelines), id: \.guidelineId) { position in
                VStack(alignment: .leading, spacing: 0) {
                    Text(sourceName(position.guidelineId))
                        .font(.hepCaptionBold)
                        .foregroundStyle(Color.hepNavy)
                    Text(CardMarkup.attributedString(position.text))
                        .font(.hepCaption)
                        .foregroundStyle(Color.hepInk)
                }
                .accessibilityElement(children: .combine)
            }
            if let note = row.note {
                // Italic like the lessons' "why it matters" lines; ink, not
                // muted — it is content, not a source line.
                Text(CardMarkup.attributedString(note))
                    .font(.hepSubtitle)
                    .foregroundStyle(Color.hepInk)
                    .padding(.top, Spacing.xs)
            }
        }
    }

    /// "Society Year" from the registry; the raw id if it is missing
    /// (the integrity gate forbids that in shipped content).
    private func sourceName(_ id: String) -> String {
        guard let g = byID[id] else { return id }
        return "\(g.society) \(g.year)"
    }

    /// Citations of the distinct documents compared, in row order.
    private var citations: [String] {
        let byID = byID
        var seen = Set<String>()
        return block.rows
            .flatMap { $0.orderedPositions(in: registryGuidelines) }
            .compactMap { position in
                guard seen.insert(position.guidelineId).inserted else { return nil }
                return byID[position.guidelineId]?.citation
            }
    }
}
