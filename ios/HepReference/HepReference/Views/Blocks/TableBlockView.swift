import SwiftUI

/// No horizontal ScrollView — content tables are kept to 2–3 columns
/// short enough to wrap on a phone width, so the Grid just fills the card's
/// own width directly (inherited from SectionCard).
struct TableBlockView: View {
    let block: TableBlock
    /// Lets a pathway `box` that wraps a single `table` child (see
    /// `PathwayNodeView`) hand its own tier tint straight to this view's
    /// `SectionCard` instead of nesting a second, differently-tinted card
    /// inside the first — same reasoning as `PathwayNodeView`'s
    /// `unwrapSingleBox` for a `section` wrapping a single `box`.
    var background: Color = Color.hepSurface
    /// Navy for a top-level table block; a pathway passes its box's tier
    /// color, or nil for a bare table inside an already-framed section.
    var stripe: Color? = Color.hepNavy

    var body: some View {
        SectionCard(background: background, stripe: stripe) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                BlockHeading(text: block.h)
                // The lessons' table (CLAUDE.md §12.3): navy header row
                // with bold `onSolid` text, zebra rows surface/background,
                // first column bold. Zero grid spacing so each row's fill
                // runs edge to edge; the cells carry their own padding.
                Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
                    GridRow {
                        ForEach(Array(block.head.enumerated()), id: \.offset) { _, cell in
                            Text(cell)
                                .font(.hepTag)
                                .foregroundStyle(Color.hepOnSolid)
                                .multilineTextAlignment(.leading)
                                .modifier(TableCell(fill: Color.hepNavy))
                        }
                    }
                    ForEach(Array(block.rows.enumerated()), id: \.offset) { rowIndex, row in
                        GridRow {
                            ForEach(Array(row.enumerated()), id: \.offset) { column, cell in
                                Text(CardMarkup.attributedString(cell))
                                    .font(column == 0 ? .hepCaptionBold : .hepCaption)
                                    .foregroundStyle(Color.hepInk)
                                    .multilineTextAlignment(.leading)
                                    .modifier(TableCell(fill: rowIndex.isMultiple(of: 2) ? Color.hepBackground : Color.hepSurface))
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
            }
        }
    }
}

/// One table cell: padded, stretched to fill its grid cell in both
/// directions (so a short cell's fill matches the tallest one in its row),
/// then filled. `maxHeight: .infinity` relies on the Grid sizing each row
/// to its tallest cell (the `fixedSize` above keeps text at its ideal
/// height) — fine in a scrolling card, but a table under a fixed-height
/// parent would stretch.
private struct TableCell: ViewModifier {
    let fill: Color

    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.xs + 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(fill)
    }
}
