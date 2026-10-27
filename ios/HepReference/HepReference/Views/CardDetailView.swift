import SwiftUI

struct CardDetailView: View {
    let card: Card
    /// Per-card choices (age branch); a linked card pushed on top gets its own.
    @State private var session = CardSession()

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
        .environment(session)
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
                HeaderBackButton()
                CardHeaderView(card: card)
                    .padding(.trailing, Spacing.l)
            }
            DoubleRule()
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.xs)
        }
        .background(Color.hepBackground)
    }
}
