import SwiftUI

struct KVBlockView: View {
    let block: KVBlock

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                BlockHeading(text: block.h)
                ForEach(Array(block.rows.enumerated()), id: \.offset) { _, row in
                    HStack(alignment: .firstTextBaseline) {
                        Text(row.key)
                            .font(.hepBody)
                            .foregroundStyle(Color.hepMuted)
                        Spacer(minLength: Spacing.m)
                        Text(CardMarkup.attributedString(row.value))
                            .font(.hepBody.monospacedDigit())
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
    }
}
