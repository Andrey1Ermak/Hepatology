import SwiftUI

/// Wraps subviews left-to-right, each sized to its own content, moving to a
/// new row when the current one runs out of width — like text wrapping.
/// Replaces the `LazyVGrid(columns: [.adaptive(minimum:)])` chip grids,
/// whose uniform-minimum-width cells made long clinical sentences (e.g.
/// alternate-diagnosis chips) wrap raggedly across an unpredictable
/// number of lines.
/// A subview wider than the available row width still gets its own row
/// (measured against that width so it wraps internally, never overflows).
struct FlowLayout: Layout {
    var horizontalSpacing: CGFloat = Spacing.s
    var verticalSpacing: CGFloat = Spacing.s

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = computeRows(maxWidth: maxWidth, subviews: subviews)
        let height = rows.reduce(CGFloat(0)) { $0 + $1.height } + verticalSpacing * CGFloat(max(0, rows.count - 1))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                item.subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(item.size))
                x += item.size.width + horizontalSpacing
            }
            y += row.height + verticalSpacing
        }
    }

    private struct RowItem { let subview: LayoutSubview; let size: CGSize }
    private struct Row { let items: [RowItem]; let width: CGFloat; let height: CGFloat }

    /// Measures each subview against `maxWidth` — an item whose natural
    /// (unconstrained) width already fits stays that size; one that doesn't
    /// is re-measured constrained to `maxWidth` so it wraps to its own
    /// full-width row instead of being clipped or forced narrower elsewhere.
    private func computeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentItems: [RowItem] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        func flushRow() {
            guard !currentItems.isEmpty else { return }
            rows.append(Row(items: currentItems, width: currentWidth, height: currentHeight))
            currentItems = []
            currentWidth = 0
            currentHeight = 0
        }

        for subview in subviews {
            var size = subview.sizeThatFits(.unspecified)
            if size.width > maxWidth {
                size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            }
            let extra = currentItems.isEmpty ? 0 : horizontalSpacing
            if !currentItems.isEmpty && currentWidth + extra + size.width > maxWidth {
                flushRow()
            }
            let gap = currentItems.isEmpty ? 0 : horizontalSpacing
            currentItems.append(RowItem(subview: subview, size: size))
            currentWidth += gap + size.width
            currentHeight = max(currentHeight, size.height)
        }
        flushRow()
        return rows
    }
}
