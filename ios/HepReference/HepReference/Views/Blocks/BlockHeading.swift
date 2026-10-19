import SwiftUI

/// Shared optional heading (`h`) rendered above a block's content — the
/// lesson cards' heading (CLAUDE.md §12.3): `hepSectionHeading` in ink, as
/// authored (no forced caps). `CollapsibleSection`'s title uses the same
/// treatment so blocks and pathway sections read as one family.
struct BlockHeading: View {
    let text: String?

    var body: some View {
        if let text {
            Text(text)
                .font(.hepSectionHeading)
                .foregroundStyle(Color.hepInk)
                .accessibilityAddTraits(.isHeader)
        }
    }
}
