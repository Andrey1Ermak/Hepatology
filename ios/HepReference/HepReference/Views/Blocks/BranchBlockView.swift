import SwiftUI

struct BranchBlockView: View {
    let block: BranchBlock

    var body: some View {
        SectionCard(stripe: Color.hepNavy) {
            VStack(alignment: .leading, spacing: Spacing.m) {
                BlockHeading(text: block.h)
                ForEach(Array(block.opts.enumerated()), id: \.offset) { _, opt in
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(CardMarkup.attributedString(opt.if))
                            .font(.hepRowLabel)
                            .foregroundStyle(Color.hepMuted)
                        Text(CardMarkup.attributedString(opt.then))
                            .font(.hepBody)
                    }
                }
            }
        }
    }
}
