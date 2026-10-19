import SwiftUI

/// Tracks each category header's offset within the scroll content, keyed by
/// section index — see `CardListView`'s doc comment for why.
private struct SectionHeaderOffsetKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct CardListView: View {
    let library: CardLibrary
    @State private var pinnedCategory: CardCategory?
    /// Accumulated last-known offset per section index. `LazyVStack`
    /// deallocates header views once they scroll far enough off-screen, so a
    /// section that already scrolled past can simply stop appearing in a
    /// given `onPreferenceChange` payload — that's not the same as "not yet
    /// passed." Merging into this persistent dictionary (never dropping a
    /// key just because its view went away) instead of trusting each
    /// payload's key set as the complete truth is what fixes that: once a
    /// section is known to have passed, it stays known, even if both it and
    /// everything after it have long scrolled out of the render buffer.
    @State private var knownSectionOffsets: [Int: CGFloat] = [:]
    @State private var path: [String] = []

    init(library: CardLibrary) {
        self.library = library
        _pinnedCategory = State(initialValue: library.groupedSections.first?.category)
        #if DEBUG
        // `-hepOpenCard <id>` opens a card on launch, so tools/screenshot.sh
        // can capture a card screen without UI automation.
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-hepOpenCard"), args.indices.contains(i + 1) {
            _path = State(initialValue: [args[i + 1]])
        }
        #endif
    }

    var body: some View {
        NavigationStack(path: $path) {
            // Hybrid design: the *real* category headers are ordinary,
            // visible content inside the LazyVStack — they scroll normally,
            // so on a tall screen you can see one category's tail and the
            // next category's header/cards at the same time, like Contacts.
            // On top of that, one more copy of "whichever category is
            // currently at the top" is drawn as a fixed ZStack overlay. That
            // duplicate is what makes the opacity guarantee unconditional:
            // it's composited last, always above the ScrollView, so nothing
            // scrolling underneath — including a real header transiting past
            // the top — can ever render above it. Earlier attempts relied on
            // `List`'s or `LazyVStack`'s own "pin to top" positioning *as*
            // the opacity guarantee, and that positioning was occasionally
            // wrong on-device (a card rendered above the header). This
            // doesn't have that failure mode: the overlay's presence needs no
            // position math to hold, only its *text* does (via the offset
            // tracking below), and getting that text briefly wrong just means
            // a label transitions a beat late — never a visibility bug.
            ZStack(alignment: .top) {
                Color.hepBackground.ignoresSafeArea()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: Spacing.s) {
                        ForEach(Array(library.groupedSections.enumerated()), id: \.element.section) { index, group in
                            categoryHeaderContent(group.category)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.preference(
                                            key: SectionHeaderOffsetKey.self,
                                            value: [index: geo.frame(in: .named("browseScroll")).minY]
                                        )
                                    }
                                )
                            LazyVGrid(columns: GridLayout.twoColumns, spacing: Spacing.s) {
                                ForEach(group.cards) { card in
                                    cardLink(card)
                                }
                            }
                            .padding(.horizontal, Spacing.l)
                        }
                    }
                }
                // A ScrollView inside a ZStack isn't automatically told to
                // claim the full available space — without this it can size
                // to its initial content instead of the screen.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .coordinateSpace(name: "browseScroll")
                .onPreferenceChange(SectionHeaderOffsetKey.self) { offsets in
                    for (index, offset) in offsets {
                        knownSectionOffsets[index] = offset
                    }
                    let sections = library.groupedSections
                    let passedIndex = knownSectionOffsets.filter { $0.value <= 0 }.keys.max() ?? 0
                    if sections.indices.contains(passedIndex) {
                        pinnedCategory = sections[passedIndex].category
                    }
                }

                if let pinnedCategory {
                    categoryHeaderContent(pinnedCategory)
                }
            }
            // No nav title/bar here — Browse is the tab's root screen, there's
            // no back button to show, and "Browse" as a title only ate space;
            // CardDetailView still gets its own nav bar (with back button)
            // since bar visibility is set per-screen.
            .toolbar(.hidden, for: .navigationBar)
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

    /// A lesson-style section heading: maroon roman-numeral badge (the
    /// category's Browse position) and the name in navy Heavy caps. The
    /// bottom rule deliberately isn't a plain `Divider()` — that uses the
    /// translucent `UIColor.separator`, and this header must stay opaque
    /// above the cards scrolling under it.
    private func categoryHeaderContent(_ category: CardCategory) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.s) {
                if let number = RomanNumeral.string(category.number) {
                    SectionNumberBadge(text: number)
                }
                Text(category.displayName)
                    .hepTitleStyle()
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.s)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            Rectangle()
                .fill(Color.hepInk)
                .frame(height: 1)
                .padding(.horizontal, Spacing.l)
        }
        .background(Color.hepBackground)
    }

    /// A card row, styled as an elevated card (not a bare List row).
    private func cardLink(_ card: Card) -> some View {
        NavigationLink(value: card.id) {
            CardRowView(card: card)
        }
        .buttonStyle(.plain)
    }
}
