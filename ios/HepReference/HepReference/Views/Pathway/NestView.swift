import SwiftUI

/// Indented nested content, matching template.html's `.asnest` — the tree-
/// connector rendering itself lives in `BranchedChildrenView` (shared with
/// `ArmView`, since an arm's own direct out→nest chain needs the exact same
/// treatment), so a branch's sub-content connects into the same tree as its
/// parent instead of restarting as a visually orphaned block.
struct NestView: View {
    let children: [PathwayNode]

    var body: some View {
        BranchedChildrenView(children: children)
    }
}
