import SwiftUI

/// The page title, not a content block — deliberately not a `SectionCard`
/// (no stroke, no shadow), so it doesn't read as just another card in the
/// scroll. No background tint of its own — it sits inside
/// `CardDetailView`'s fixed header, which already paints `appBackground`
/// behind it, and the title itself matches Browse's category header style
/// (see CardListView.categoryHeaderContent).
struct CardHeaderView: View {
    let card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(card.title)
                .font(.hepDisplay(.title3, weight: .bold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(Color("brandAccent"))
            if let subtitle = card.subtitle {
                Text(subtitle)
                    .font(.hepCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
