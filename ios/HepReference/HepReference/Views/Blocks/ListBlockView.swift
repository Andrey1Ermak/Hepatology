import SwiftUI

struct ListBlockView: View {
    let block: ListBlock

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                BlockHeading(text: block.h)
                ForEach(Array(block.items.enumerated()), id: \.offset) { _, item in
                    itemView(item)
                }
            }
        }
    }

    @ViewBuilder
    private func itemView(_ item: ListItem) -> some View {
        switch item {
        case .plain(let text):
            bullet(CardMarkup.attributedString(text))
        case .titled(let title, let sub):
            VStack(alignment: .leading, spacing: Spacing.xs) {
                bullet(AttributedString(title), bold: true)
                ForEach(Array(sub.enumerated()), id: \.offset) { _, line in
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.s) {
                        Text("–").foregroundStyle(.secondary)
                        Text(CardMarkup.attributedString(line)).font(.hepBody)
                    }
                    .padding(.leading, Spacing.l)
                }
            }
        }
    }

    private func bullet(_ text: AttributedString, bold: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.s) {
            Text("•").foregroundStyle(.secondary)
            Text(text).font(.hepBody).fontWeight(bold ? .semibold : .regular)
        }
    }
}
