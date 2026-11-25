import SwiftUI

/// The Home tab (§4.1): one tile per clinical category — entry by problem,
/// not by diagnosis — with Reference set apart underneath. A tile opens the
/// category's card list (`CategoryView`), so any card is two taps from here.
/// Categories without a bundled card are not shown (§10: no placeholders).
struct HomeView: View {
    let library: CardLibrary
    @Environment(CardHistory.self) private var history: CardHistory?
    @State private var path = NavigationPath()
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(library: CardLibrary) {
        self.library = library
        #if DEBUG
        // `-hepOpenCategory <cat>` and `-hepOpenCard <id>` push a category
        // and/or a card on launch, so tools/screenshot.sh can capture those
        // screens without UI automation.
        let args = ProcessInfo.processInfo.arguments
        var initial = NavigationPath()
        if let i = args.firstIndex(of: "-hepOpenCategory"), args.indices.contains(i + 1),
           let category = CardCategory(rawValue: args[i + 1]) {
            initial.append(category)
        }
        if let i = args.firstIndex(of: "-hepOpenCard"), args.indices.contains(i + 1) {
            initial.append(args[i + 1])
        }
        _path = State(initialValue: initial)
        #endif
    }

    var body: some View {
        let sections = library.homeSections
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    masthead
                    if let history {
                        CardShortcutRow(title: "Favorites", symbol: "star.fill", cards: library.cards(ids: history.favorites))
                        CardShortcutRow(title: "Recent", symbol: "clock", cards: library.cards(ids: history.recents))
                    }
                    if !sections.problems.isEmpty {
                        // One column at accessibility sizes, so no category name is cut.
                        LazyVGrid(columns: GridLayout.tiles(for: dynamicTypeSize), spacing: Spacing.s) {
                            ForEach(sections.problems, id: \.category) { section in
                                tileLink(section)
                            }
                        }
                    }
                    if let reference = sections.reference {
                        tileLink(reference)
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.l)
            }
            .background(Color.hepBackground.ignoresSafeArea())
            // Home is the tab's root — no back button, and a system title
            // would only repeat the masthead.
            .toolbar(.hidden, for: .navigationBar)
            .swipeBackEnabled()
            .navigationDestination(for: CardCategory.self) { category in
                CategoryView(category: category, cards: library.cards(in: category))
            }
            .navigationDestination(for: String.self) { id in
                if let card = library.cardsByID[id] {
                    CardDetailView(card: card)
                }
                #if DEBUG
                if id == DesignSampleView.id {
                    DesignSampleView()
                }
                #endif
            }
        }
    }

    /// The app's own lesson-style title block: kicker, title, a one-line
    /// promise in the subtitle face, and the lessons' double rule.
    private var masthead: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            KickerLine(text: "Pediatric hepatology")
            Text("HepReference")
                .hepTitleStyle()
                .accessibilityAddTraits(.isHeader)
            Text("Start from the problem in front of you")
                .font(.hepSubtitle)
                .foregroundStyle(Color.hepMuted)
            DoubleRule()
                .padding(.top, Spacing.xs)
        }
        .padding(.top, Spacing.s)
    }

    private func tileLink(_ section: CardLibrary.CategorySection) -> some View {
        NavigationLink(value: section.category) {
            CategoryTile(category: section.category, cardCount: section.cards.count)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(CategoryTile.accessibilityLabel(section.category, cardCount: section.cards.count))
        .accessibilityAddTraits(.isButton)
    }
}

/// Favorites or Recent on Home: a kicker, then the cards as a sideways row
/// of small tiles, one tap from the card. Absent when empty (§10: no
/// placeholders), so a first launch shows only the categories.
struct CardShortcutRow: View {
    let title: String
    let symbol: String
    let cards: [Card]
    /// One tile width per row, wide enough for two-line titles.
    @ScaledMetric(relativeTo: .subheadline) private var tileWidth: CGFloat = 176
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Linear scaling would make a tile wider than the screen at the
    /// largest sizes; cap it and give long titles a third line instead.
    private var cappedWidth: CGFloat { min(tileWidth, 280) }

    var body: some View {
        if !cards.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: symbol)
                        .font(.hepIconSmall)
                        .foregroundStyle(Color.hepBlue)
                        .accessibilityHidden(true)
                    Text(title)
                        .hepKickerStyle()
                        .accessibilityAddTraits(.isHeader)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: Spacing.s) {
                        ForEach(cards) { card in
                            NavigationLink(value: card.id) {
                                tile(card)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(card.title)
                            .accessibilityHint("Opens the card")
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                    .padding(.horizontal, Spacing.l)
                }
                // The tiles' soft shadow would otherwise end in a hard edge.
                .scrollClipDisabled()
                // Tiles scroll edge to edge, but start aligned with the page.
                .padding(.horizontal, -Spacing.l)
            }
        }
    }

    private func tile(_ card: Card) -> some View {
        SectionCard(background: card.cat == .ref ? Color.hepSurface : Color.hepCard, stripe: Color.hepNavy) {
            // Word joiners keep "0–3" on one line in a narrow tile.
            Text(card.gridTitle.replacingOccurrences(of: "–", with: "\u{2060}–\u{2060}"))
                .font(.hepSectionHeading)
                .foregroundStyle(Color.hepInk)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(width: cappedWidth)
    }
}

/// A home-screen category tile (§12.3): a white card with a navy top
/// stripe, navy icon and the name in the section-heading face. Reference
/// sits back on `surface` and spans the full width.
struct CategoryTile: View {
    let category: CardCategory
    let cardCount: Int
    /// One icon box for every symbol, so tall and short glyphs leave the
    /// name on the same baseline in neighboring tiles.
    @ScaledMetric(relativeTo: .subheadline) private var iconBox: CGFloat = 28

    private var countText: String { Self.countText(cardCount) }

    static func countText(_ count: Int) -> String {
        count == 1 ? "1 card" : "\(count) cards"
    }

    /// Read by VoiceOver for the whole tile, e.g. "Reference, 1 card".
    static func accessibilityLabel(_ category: CardCategory, cardCount: Int) -> String {
        "\(category.displayName), \(countText(cardCount))"
    }

    var body: some View {
        SectionCard(background: category == .ref ? Color.hepSurface : Color.hepCard, stripe: Color.hepNavy) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                HStack(alignment: .top) {
                    Image(systemName: category.symbol)
                        .font(.hepSectionHeading)
                        .imageScale(.large)
                        .foregroundStyle(Color.hepNavy)
                        .frame(width: iconBox, height: iconBox, alignment: .leading)
                    Spacer(minLength: Spacing.s)
                    if let number = RomanNumeral.string(category.number) {
                        SectionNumberBadge(text: number)
                    }
                }
                // Two lines reserved for every name, so all tiles in a row
                // keep one height without shrinking any title.
                Text(category.displayName)
                    .font(.hepSectionHeading)
                    .foregroundStyle(Color.hepInk)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                Text(countText)
                    .font(.hepSubtitle)
                    .foregroundStyle(Color.hepMuted)
            }
        }
    }
}

#Preview {
    let library = CardLibrary()
    return HomeView(library: library)
        .environment(library)
        .environment(Registry())
        .environment(CardHistory())
}
