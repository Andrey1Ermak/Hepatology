import SwiftUI

private struct PathwayAccentKey: EnvironmentKey {
    static let defaultValue: Color = Color.hepRule
}

extension EnvironmentValues {
    /// The enclosing arm's own tier color, threaded down so a nested
    /// branch's tree-connector lines pick up that arm's own accent instead
    /// of a flat gray — ties the connector visually to "this is
    /// still inside the same severity-colored arm" rather than introducing
    /// an unrelated third color. Falls back to a neutral gray outside any
    /// arm (shouldn't normally happen — `out`/`nest` only appear inside one).
    var pathwayAccent: Color {
        get { self[PathwayAccentKey.self] }
        set { self[PathwayAccentKey.self] = newValue }
    }
}

/// A rounded tree-connector "elbow": enters at the top, curves into a
/// horizontal tick at the shape's own vertical midpoint. When
/// `continuesBelow` is true, the vertical trunk also continues from the
/// midpoint down to the bottom of the shape's frame, so consecutive
/// branches chain into one unbroken trunk instead of restarting per child.
///
/// `radius` is clamped to what the shape's own rect can actually fit — a
/// short row (little vertical room above `midY`) or a narrow tick region
/// must never make the curve overshoot past `rect.maxY`/`rect.maxX` into a
/// malformed path.
private struct TreeBranchShape: Shape {
    let cornerRadius: CGFloat
    let continuesBelow: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        let radius = min(cornerRadius, rect.width, midY - rect.minY)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: midY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: midY),
            control: CGPoint(x: rect.minX, y: midY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: midY))
        if continuesBelow {
            path.move(to: CGPoint(x: rect.minX, y: midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        return path
    }
}

/// Renders a sequence of pathway nodes with tree-style branch connectors —
/// used by both `ArmView` (its own direct children) and `NestView` (a
/// branch's own indented sub-children), so an out→nest chain reads as one
/// connected tree regardless of which level it's at.
///
/// Only `.out` ever gets a connector, and only when the very next sibling
/// is *directly*, immediately another `.out` — a condition's own two
/// alternatives (e.g. two dispositions of one shared decision). `.row`
/// (and `.nest`/`.col`/`.box`/`.table`) never draws a line, full stop,
/// regardless of what precedes or follows it.
///
/// An earlier version let the *last* row before a branch carry a
/// connecting stub, to visually bridge "these criteria bullets lead into
/// this decision." That broke the bulleted list's own visual language: a
/// bullet list reads as uniform, identical dots down the left edge — every
/// row *is* a bullet, structurally interchangeable with its neighbors. The
/// tree-connector is a second, different marking system (elbows/ticks, not
/// dots). Giving exactly one row in an otherwise-uniform list an extra tail
/// the others don't have mixes those two systems on a single row and reads
/// as an unexplained inconsistency, not a meaningful connection — worse
/// than no connection at all. Bullet lists and the tree stay visually
/// separate now: a list's relationship to what follows it is conveyed by
/// indentation and reading order alone, the same way it already is for
/// `.row` content that precedes an unrelated top-level `.out` (e.g. three
/// independent severity categories in a row).
struct BranchedChildrenView: View {
    let children: [PathwayNode]

    @Environment(\.pathwayAccent) private var lineColor

    private let connectorWidth: CGFloat = Spacing.m
    private let trunkInset: CGFloat = Spacing.xs
    private let cornerRadius: CGFloat = Spacing.xs
    private let lineWidth: CGFloat = 2
    /// Half of the old inter-row `Spacing.xs` gap, moved onto each row's own
    /// content instead of the VStack's `spacing` — the connector shape fills
    /// to match its row's full height, so pushing the breathing room inside
    /// that height (instead of into a gap between rows the connector can't
    /// reach) is what makes consecutive segments meet with no visible break.
    /// A `spacing`-based gap read as a dashed/dotted line, not one piece.
    private let rowPadding: CGFloat = Spacing.xs / 2

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(children.enumerated()), id: \.offset) { index, node in
                row(for: node, index: index)
            }
        }
    }

    /// True only when the child directly at `index + 1` — immediately,
    /// with nothing between — is itself an `.out`.
    private func nextIsOut(after index: Int) -> Bool {
        let next = index + 1
        guard next < children.count, case .out = children[next] else { return false }
        return true
    }

    @ViewBuilder
    private func row(for node: PathwayNode, index: Int) -> some View {
        switch node {
        case .out:
            content(node)
                // `.overlay(alignment:)`, not a `ZStack` sibling — SwiftUI
                // proposes the *exact* resolved size of `content(node)` to
                // this overlay, so the shape's rect.height is unambiguously
                // this row's own height. A bare `Shape` as a ZStack sibling
                // has no such guarantee (its own unconstrained "ideal" size
                // can disagree with its sibling's), which is what produced
                // short, disconnected segments instead of one line.
                .overlay(alignment: .topLeading) {
                    // The tick stops `trunkInset` short of the content
                    // instead of reaching all the way to it — the gap
                    // between the tick's end and the badge now matches the
                    // gap between the container's own edge and the trunk,
                    // so the line reads as floating near its content, not
                    // physically plugging into it.
                    TreeBranchShape(cornerRadius: cornerRadius, continuesBelow: nextIsOut(after: index))
                        .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                        .frame(width: connectorWidth - 2 * trunkInset)
                        .padding(.leading, trunkInset)
                }
        default:
            content(node)
        }
    }

    /// A `.nest` row's *own* vertical padding stacks on top of the padding
    /// its inner `BranchedChildrenView` already gives its own first/last
    /// child — a marker followed by a `.nest` (e.g. "IMPROVED/RESOLVED" →
    /// nest[HIGH BIPHASIC RISK...]) gets 3 half-gaps (this row's bottom +
    /// the nest row's top + the nest's own first child's top) where a flat
    /// sequence with no intervening `.nest` (e.g. "ADJUNCTS" → table →
    /// "STABLE VITALS") only ever gets 2, reading as a visibly bigger gap
    /// at exactly the seams where a `.nest` is involved. A `.nest` row
    /// contributes no content of its own — it's pure indentation — so it
    /// shouldn't add its own padding on top of what its children provide.
    private func isNest(_ node: PathwayNode) -> Bool {
        if case .nest = node { return true }
        return false
    }

    private func content(_ node: PathwayNode) -> some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: connectorWidth)
            PathwayNodeView(node: node)
        }
        .padding(.vertical, isNest(node) ? 0 : rowPadding)
    }
}
