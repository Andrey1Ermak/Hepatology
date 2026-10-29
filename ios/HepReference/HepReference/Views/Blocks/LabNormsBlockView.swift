import SwiftUI

/// Age- and sex-specific limits for the block's analytes (CLAUDE.md §5.2),
/// read from `Registry/labs.json` — the block itself carries no numbers.
/// One lessons-style table per analyte (navy header, zebra rows, bold first
/// column). The row for the age chosen in the card's `age_switch` is tinted
/// and marked, so the limit that applies is the one the eye lands on.
struct LabNormsBlockView: View {
    let block: LabNormsBlock
    /// Injected by previews and the design sample; nil reads the app's registry.
    var labs: [LabTest]?

    @Environment(Registry.self) private var registry: Registry?
    @Environment(CardSession.self) private var session: CardSession?

    private var tests: [LabTest] { block.labTests(in: labs ?? registry?.labs ?? []) }

    var body: some View {
        // Unreachable in shipped content (the integrity gate requires every
        // analyte to resolve), but never render a bare heading.
        if !tests.isEmpty {
            card
        }
    }

    private var card: some View {
        SectionCard(stripe: Color.hepNavy) {
            VStack(alignment: .leading, spacing: Spacing.m) {
                BlockHeading(text: block.h)
                ForEach(tests) { test in
                    table(for: test)
                }
                CitationFooter(citations: sources)
            }
        }
    }

    private func table(for test: LabTest) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("\(test.name) · \(test.unit)")
                .hepKickerStyle()
                .accessibilityAddTraits(.isHeader)
            Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    ForEach(["Age", "Sex", test.limitHeading], id: \.self) { title in
                        Text(title)
                            .font(.hepTag)
                            .foregroundStyle(Color.hepOnSolid)
                            .modifier(TableCell(fill: Color.hepNavy))
                    }
                }
                // Each row's spoken label already names every column.
                .accessibilityHidden(true)
                ForEach(Array(test.bands.enumerated()), id: \.offset) { index, band in
                    row(band, index: index, test: test)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.small))
            if let note = test.note {
                Text(note)
                    .font(.hepCaption)
                    .foregroundStyle(Color.hepInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func row(_ band: LabBand, index: Int, test: LabTest) -> some View {
        let isSelected = band.matches(session?.age)
        let fill = isSelected ? Tier.ref.tint : (index.isMultiple(of: 2) ? Color.hepBackground : Color.hepSurface)
        return GridRow {
            HStack(spacing: Spacing.xs) {
                Text(band.ageLabel).font(.hepCaptionBold)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.hepIconSmall)
                        .foregroundStyle(Color.hepNavy)
                }
            }
            .modifier(TableCell(fill: fill))
            // A GridRow hands its modifiers to every cell, so the row is
            // spoken once from its first cell and the others are hidden.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(test.name), \(band.ageLabel.replacingOccurrences(of: "–", with: " to ")), \(band.sexLabel): \(band.spokenRange) \(test.unit)")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            Text(band.sexLabel)
                .font(.hepCaption)
                .modifier(TableCell(fill: fill))
                .accessibilityHidden(true)
            Text(band.rangeText)
                .font(.hepCaptionBold.monospacedDigit())
                .modifier(TableCell(fill: fill))
                .accessibilityHidden(true)
        }
        .foregroundStyle(Color.hepInk)
    }

    /// Citations of the distinct sources behind the shown limits.
    private var sources: [String] {
        var seen = Set<String>()
        return tests.flatMap(\.bands).compactMap { band in
            guard seen.insert(band.source).inserted else { return nil }
            return registry?.guideline(band.source)?.citation
        }
    }
}
