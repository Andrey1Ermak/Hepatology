import SwiftUI

/// The Home tab (§4.1): one tile per clinical category — entry by problem,
/// not by diagnosis — with Reference set apart underneath. A tile opens the
/// category's card list (`CategoryView`), so any card is two taps from here.
/// Categories without a bundled card are not shown (§10: no placeholders).
struct HomeView: View {
    let library: CardLibrary
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
                    if !sections.problems.isEmpty {
                        // One column at accessibility sizes, so no category name is cut.
                        LazyVGrid(columns: dynamicTypeSize.isAccessibilitySize ? GridLayout.oneColumn : GridLayout.twoColumns, spacing: Spacing.s) {
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
}
