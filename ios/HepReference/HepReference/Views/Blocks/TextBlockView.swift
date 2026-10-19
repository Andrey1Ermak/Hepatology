import SwiftUI

struct TextBlockView: View {
    let block: TextBlock

    var body: some View {
        SectionCard(stripe: Color.hepNavy) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                BlockHeading(text: block.h)
                Text(CardMarkup.attributedString(block.text))
                    .font(.hepBody)
            }
        }
    }
}
