import SwiftUI

/// Stand-in for a `chip_screen`/`pathway`/`score_calc`/`numeric_calc` block
/// whose `calc_id`/`path_id` doesn't resolve to bundled content. Confirmed by
/// `AllBundledCardsDecodeTests.testEveryCardCustomBlockResolves` to never
/// actually trigger for any of the 78 shipped cards — a pure defensive
/// fallback, not a "feature coming soon" message.
struct PlaceholderBlockView: View {
    let kind: String
    let label: String

    var body: some View {
        SectionCard {
            HStack(spacing: Spacing.s) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.hepBody.weight(.medium))
                    Text("\(kind) content unavailable")
                        .font(.hepCaption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }
}
