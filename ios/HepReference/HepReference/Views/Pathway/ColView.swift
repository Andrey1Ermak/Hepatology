import SwiftUI

/// A plain vertical grouping of content ("col" in template.html) — visual
/// grouping only, not a multi-column layout (iOS reads pathways as one
/// vertical scroll). Uses `Spacing.xs`, matching `GrpView`'s row spacing —
/// on-device review found `col` (e.g. hb's "First steps") and a `group`'s
/// rows (e.g. "ongoing management") reading at two different densities
/// even though both are just a list of bullet rows.
struct ColView: View {
    let children: [PathwayNode]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            ForEach(Array(children.enumerated()), id: \.offset) { _, node in
                PathwayNodeView(node: node)
            }
        }
    }
}
