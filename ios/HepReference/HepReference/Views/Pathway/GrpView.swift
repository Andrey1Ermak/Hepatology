import SwiftUI

/// A labeled group header followed by its content, matching template.html's
/// `.asre`/`.asrelbl`. The label reuses `Badge` (style: `.neutral`) — the
/// same pill treatment as a pathway outcome's condition label (see
/// `OutView`) — instead of bare caption text, so a labeled subgroup reads as
/// a designed element rather than plain text.
///
/// Previously had a dashed left guide line (`VLine`, added in Phase P4 to
/// distinguish it from `NestView`'s dotted one); dropped after on-device
/// review found both guides' start/end unclear rather than a legible
/// signal. Indentation alone now carries the hierarchy, same as `NestView`.
/// Uses `Spacing.s`, not `.m`: a group most often sits inside a `SectionCard`
/// or `box`, which already contributes its own `Spacing.m` padding — stacking
/// two full `.m` insets read as an oversized, unintentional-looking gap
/// between the badge and the block's edge.
struct GrpView: View {
    let label: String
    let children: [PathwayNode]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Badge(text: label, style: .neutral)
            ForEach(Array(children.enumerated()), id: \.offset) { _, node in
                PathwayNodeView(node: node)
            }
        }
        .padding(.leading, Spacing.s)
    }
}
