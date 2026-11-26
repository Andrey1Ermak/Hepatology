import SwiftUI

struct CardDetailView: View {
    let card: Card
    /// Per-card choices (age branch); a linked card pushed on top gets its own.
    @State private var session = CardSession()
    @Environment(CardHistory.self) private var history: CardHistory?
    /// The launch scroll (`-hepScrollToBlock`) runs once, not on every return.
    @State private var didLaunchScroll = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    ForEach(Array(card.blocks.enumerated()), id: \.offset) { index, block in
                        BlockView(block: block)
                            .id(index)
                    }
                    CardLinksView(card: card)
                }
                .padding(Spacing.l)
            }
            .onAppear { scrollToLaunchBlock(proxy) }
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
        .swipeBackEnabled()
        // Also on return from a linked card: the card on screen is the
        // most recent one.
        .onAppear { history?.recordVisit(card.id) }
    }

    /// Debug builds only: with `-hepOpenCard <id>`, `-hepScrollToBlock <n>`
    /// opens that card scrolled to block n (0-based), once, so
    /// `tools/screenshot.sh` can show blocks below the fold
    /// (`HEP_SCROLL_BLOCK`). Other cards are left alone.
    private func scrollToLaunchBlock(_ proxy: ScrollViewProxy) {
        #if DEBUG
        guard !didLaunchScroll else { return }
        didLaunchScroll = true
        let args = ProcessInfo.processInfo.arguments
        guard let c = args.firstIndex(of: "-hepOpenCard"), args.indices.contains(c + 1),
              args[c + 1] == card.id,
              let i = args.firstIndex(of: "-hepScrollToBlock"), args.indices.contains(i + 1),
              let index = Int(args[i + 1]), card.blocks.indices.contains(index) else { return }
        DispatchQueue.main.async { proxy.scrollTo(index, anchor: .top) }
        #endif
    }

    /// Back button beside the title block, the lessons' double rule
    /// spanning the full width underneath.
    private var fixedHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                HeaderBackButton()
                CardHeaderView(card: card)
                FavoriteButton(cardID: card.id)
                    .padding(.trailing, Spacing.s)
            }
            DoubleRule()
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.xs)
        }
        .background(Color.hepBackground)
    }
}
