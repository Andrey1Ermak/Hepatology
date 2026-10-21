import SwiftUI

/// Renders a card's full pathway tree — the top level is always a list of
/// `.section`s shown as one vertical scroll.
struct PathwayBlockView: View {
    let pathway: Pathway

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            ForEach(Array(pathway.children.enumerated()), id: \.offset) { _, node in
                PathwayNodeView(node: node)
            }
        }
    }
}

/// Dispatches one `PathwayNode` to its renderer.
struct PathwayNodeView: View {
    let node: PathwayNode

    /// A `.section` usually wraps exactly one `.box` — its whole content,
    /// colored per that box's style. Unwrap it so the box's own color
    /// becomes the `CollapsibleSection`'s background directly, instead of
    /// nesting a second colored box inside the collapsible card. A section
    /// with any other shape (multiple children, no box) just gets the
    /// default `hepSurface` and navy stripe, its children rendered as-is;
    /// a single box hands over its tier tint and tier stripe.
    private static func unwrapSingleBox(_ children: [PathwayNode]) -> (background: Color, stripe: Color, children: [PathwayNode]) {
        guard children.count == 1, case .box(let style, let boxChildren) = children[0] else {
            return (Color.hepSurface, Color.hepNavy, children)
        }
        return (style.tier?.tint ?? Color.hepSurface, style.tier?.solid ?? Color.hepNavy, boxChildren)
    }

    var body: some View {
        switch node {
        case .section(let heading, let children):
            let (background, stripe, innerChildren) = Self.unwrapSingleBox(children)
            CollapsibleSection(title: heading, background: background, stripe: stripe) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    ForEach(Array(innerChildren.enumerated()), id: \.offset) { _, child in
                        PathwayNodeView(node: child)
                    }
                }
            }
        case .box(let style, let children):
            // A box wrapping a single table (e.g. fnpath's modifier-lookup
            // table) hands its tint straight to TableBlockView's own
            // SectionCard, same unwrapping reasoning as `unwrapSingleBox`
            // below — otherwise the table's own SectionCard nests a second,
            // neutrally-tinted card inside the box's colored one.
            if children.count == 1, case .table(let head, let rows) = children[0] {
                TableBlockView(block: TableBlock(h: nil, head: head, rows: rows), background: style.tier?.tint ?? Color.hepSurface, stripe: style.tier?.solid)
            } else {
                // A tiered box keeps its stripe; a plain one is just a
                // neutral panel inside its section, so no second stripe.
                SectionCard(background: style.tier?.tint ?? Color.hepSurface, stripe: style.tier?.solid) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                            PathwayNodeView(node: child)
                        }
                    }
                }
            }
        case .group(let label, let children):
            GrpView(label: label, children: children)
        case .arm(let kind, let tag, let rx, let children):
            ArmView(kind: kind, tag: tag, rx: rx, children: children)
        case .out(let condition, let pills, let subtext, let linkCalcId, let linkLabel, let condBold, let linkCardId):
            OutView(condition: condition, pills: pills, subtext: subtext, linkCalcId: linkCalcId, linkLabel: linkLabel, condBold: condBold, linkCardId: linkCardId)
        case .nest(let children):
            NestView(children: children)
        case .row(let label, let text, let bullet, let linkCalcId, let linkLabel, let linkCardId):
            RowView(label: label, text: text, bullet: bullet, linkCalcId: linkCalcId, linkLabel: linkLabel, linkCardId: linkCardId)
        case .col(let children):
            ColView(children: children)
        case .table(let head, let rows):
            TableBlockView(block: TableBlock(h: nil, head: head, rows: rows), stripe: nil)
        }
    }
}
