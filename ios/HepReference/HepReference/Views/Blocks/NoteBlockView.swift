import SwiftUI

struct NoteBlockView: View {
    let block: NoteBlock

    var body: some View {
        SectionCard(background: tier.tint, stripe: tier.solid) {
            HStack(alignment: .top, spacing: Spacing.s) {
                Image(systemName: icon)
                    .font(.hepIconMedium)
                    .foregroundStyle(tier.solid)
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    BlockHeading(text: block.h)
                    Text(CardMarkup.attributedString(block.text))
                        .font(.hepBody)
                }
            }
        }
    }

    private var tier: Tier {
        switch block.k {
        case .crit: .crit
        case .warn: .urg
        case .info: .ref
        }
    }

    private var icon: String {
        switch block.k {
        case .crit: "exclamationmark.triangle.fill"
        case .warn: "exclamationmark.circle.fill"
        case .info: "info.circle.fill"
        }
    }
}
