import SwiftUI

/// One category's cards, opened from its home-screen tile: the same
/// two-column card tiles as Search, under a fixed lesson-style header
/// (back button, numbered kicker, title, double rule) like a card's own.
struct CategoryView: View {
    let category: CardCategory
    let cards: [Card]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: GridLayout.twoColumns, spacing: Spacing.s) {
                ForEach(cards) { card in
                    NavigationLink(value: card.id) {
                        CardRowView(card: card)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.s)
        }
        .background(Color.hepBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                HeaderBackButton()
                VStack(alignment: .leading, spacing: 2) {
                    KickerLine(number: RomanNumeral.string(category.number), text: "Category")
                    Text(category.displayName)
                        .hepTitleStyle()
                        .lineLimit(2)
                        .accessibilityAddTraits(.isHeader)
                }
                .padding(.trailing, Spacing.l)
                .padding(.vertical, Spacing.xs)
            }
            DoubleRule()
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.xs)
        }
        .background(Color.hepBackground)
    }
}
