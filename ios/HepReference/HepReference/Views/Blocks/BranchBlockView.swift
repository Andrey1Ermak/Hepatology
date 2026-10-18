import SwiftUI

struct BranchBlockView: View {
    let block: BranchBlock

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: Spacing.m) {
                BlockHeading(text: block.h)
                ForEach(Array(block.opts.enumerated()), id: \.offset) { _, opt in
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(CardMarkup.attributedString(opt.if))
                            .font(.hepRowLabel)
                            .foregroundStyle(.secondary)
                        Text(CardMarkup.attributedString(opt.then))
                            .font(.hepBody)
                    }
                }
            }
        }
    }
}
