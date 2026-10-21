import SwiftUI

struct CardDetailView: View {
    let card: Card
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                ForEach(Array(card.blocks.enumerated()), id: \.offset) { _, block in
                    BlockView(block: block)
                }
                CardLinksView(card: card)
            }
            .padding(Spacing.l)
        }
        .background(Color.hepBackground.ignoresSafeArea())
        // Replaces the system nav bar's plain-font title entirely: the
        // card's own styled `CardHeaderView` now sits in a `safeAreaInset`
        // instead of scrolling as the body's first block, so it reads as a
        // fixed, opaque header (like the back button beside it) rather than
        // content that scrolls away.
        .safeAreaInset(edge: .top, spacing: 0) {
            fixedHeader
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    /// Back button beside the title block, the lessons' double rule
    /// spanning the full width underneath.
    private var fixedHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                backButton
                CardHeaderView(card: card)
                    .padding(.trailing, Spacing.l)
            }
            DoubleRule()
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.xs)
        }
        .background(Color.hepBackground)
    }

    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.hepNavy)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}
