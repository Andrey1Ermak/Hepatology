import SwiftUI

/// No horizontal ScrollView — every bundled table (this one, mtp, lyme,
/// appendicitis, adol_consent, toxidromes, sep2col) has only 2–3 columns
/// short enough to wrap on a phone width, so the Grid just fills the card's
/// own width directly (inherited from SectionCard, same as everything
/// else), with each cell set to fill its column evenly. A prior attempt
/// measured the ScrollView's width via GeometryReader/PreferenceKey and fed
/// it back in as the Grid's minWidth — that's a circular, timing-sensitive
/// dependency (a horizontally-scrolling ScrollView proposes its content
/// essentially unconstrained width, so there was never a stable value to
/// converge on) and it didn't actually fix the dead-space-on-the-right bug.
struct TableBlockView: View {
    let block: TableBlock
    /// Lets a pathway `box` that wraps a single `table` child (see
    /// `PathwayNodeView`) hand its own tier tint straight to this view's
    /// `SectionCard` instead of nesting a second, differently-tinted card
    /// inside the first — same reasoning as `PathwayNodeView`'s
    /// `unwrapSingleBox` for a `section` wrapping a single `box`.
    var background: Color = Color.hepSurface

    var body: some View {
        SectionCard(background: background) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                BlockHeading(text: block.h)
                // verticalSpacing: Spacing.xs, not `.s` — matches the tight
                // row spacing every plain-row `box` (e.g. First Steps) uses,
                // so a table doesn't read as looser than the list right
                // next to it.
                Grid(alignment: .center, horizontalSpacing: Spacing.m, verticalSpacing: Spacing.xs) {
                    GridRow {
                        ForEach(Array(block.head.enumerated()), id: \.offset) { _, cell in
                            Text(cell)
                                .font(.hepTag)
                                .foregroundStyle(Color.hepMuted)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    // .gridCellColumns spans the divider under every
                    // column — a bare Divider() here would otherwise only
                    // render under column 1 (Grid's default for a non-
                    // GridRow child), a real pre-existing rendering bug.
                    Divider().gridCellColumns(block.head.count)
                    ForEach(Array(block.rows.enumerated()), id: \.offset) { _, row in
                        GridRow {
                            ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                                // caption2, one step down from hepCaption —
                                // a dense reference table reads better
                                // smaller than regular body/row text.
                                Text(CardMarkup.attributedString(cell))
                                    .font(.hepCaption)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
    }
}
