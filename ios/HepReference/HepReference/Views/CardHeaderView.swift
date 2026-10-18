import SwiftUI

/// The page title, styled as a lesson slide's title block (CLAUDE.md §12.3):
/// kicker (maroon category number + category in blue caps) → title in navy
/// Heavy caps → source line in italic → double rule. Deliberately not a
/// `SectionCard` — it is the page heading, not another block in the scroll.
/// Sits inside `CardDetailView`'s fixed header, which paints the background.
struct CardHeaderView: View {
    let card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            KickerLine(number: RomanNumeral.string(card.cat.number), text: card.cat.displayName)
            Text(card.title)
                .hepTitleStyle()
                .accessibilityAddTraits(.isHeader)
            if let subtitle = card.subtitle {
                Text(subtitle)
                    .font(.hepSubtitle)
                    .foregroundStyle(Color.hepMuted)
            }
        }
        .padding(.vertical, Spacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
