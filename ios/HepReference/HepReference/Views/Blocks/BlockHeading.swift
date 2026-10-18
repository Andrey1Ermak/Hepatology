import SwiftUI

/// Shared optional heading (`h`) rendered above a block's content — a mono,
/// uppercase "section kicker," the same font construction as a pathway
/// `.section` node's heading (see PathwayNodeView) so both read as one
/// visual family, just at block- vs. pathway-section granularity.
struct BlockHeading: View {
    let text: String?

    var body: some View {
        if let text {
            Text(text.uppercased())
                .font(.hepSectionHeading)
                .tracking(0.6)
                .foregroundStyle(.secondary)
        }
    }
}
