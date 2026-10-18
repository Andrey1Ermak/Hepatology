import SwiftUI

struct DoseBlockView: View {
    let block: DoseBlock

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: Spacing.m) {
                BlockHeading(text: block.h)
                // A Grid (not a per-item VStack) so every drug name lines up
                // in one column and its dose(s) line up in a second column
                // across the whole block — reads as an aligned table instead
                // of N separately-stacked paragraphs.
                Grid(alignment: .topLeading, horizontalSpacing: Spacing.m, verticalSpacing: Spacing.s) {
                    ForEach(Array(block.items.enumerated()), id: \.offset) { index, item in
                        GridRow {
                            Text(item.d)
                                .font(.hepBody.weight(.semibold))
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                ForEach(Array(item.x.enumerated()), id: \.offset) { _, dose in
                                    Text(CardMarkup.attributedString(dose))
                                        .font(.hepBody.monospacedDigit())
                                }
                                if let n = item.n {
                                    Text(CardMarkup.attributedString(n))
                                        .font(.hepCaption)
                                        .foregroundStyle(Color.hepMuted)
                                }
                            }
                        }
                        if index < block.items.count - 1 {
                            Divider().gridCellColumns(2)
                        }
                    }
                }
            }
        }
    }
}
