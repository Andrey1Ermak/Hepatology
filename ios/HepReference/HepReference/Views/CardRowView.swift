import SwiftUI

struct CardRowView: View {
    let card: Card

    /// The row's inner content height (title block + code line), excluding
    /// `SectionCard`'s own padding — exposed so `SearchView`'s search field
    /// can match a card's height exactly, per the user's ask for it to read
    /// as one more tile in the same family, not a separate control.
    static let contentHeight: CGFloat = 53

    private var isDone: Bool { card.done == true }
    private var isReviewed: Bool { card.reviewed == true }
    /// `reviewed` (on-device iOS review) outranks `done` (content
    /// status) when a card happens to carry both — one badge, not two.
    private var badgeTier: Tier? {
        if isReviewed { return .urg }
        if isDone { return .rt }
        return nil
    }

    var body: some View {
        SectionCard(background: badgeTier?.tint ?? Color.hepCard) {
            HStack(spacing: Spacing.m) {
                VStack(alignment: .leading, spacing: 2) {
                    // One fixed size for every card (not a per-card
                    // `.minimumScaleFactor` — that would make some titles
                    // render smaller than others). `.footnote` (vs. `.body`
                    // elsewhere) gives single-word titles with no natural
                    // wrap point (Acetaminophen, Gastroenteritis) enough room
                    // to fit on one line at this column width, same as every
                    // other card — the true outliers that still wouldn't fit
                    // (Hyperbilirubinemia, Tachydysrhythmia) get a real short
                    // name via gridTitleOverrides instead of relying on font
                    // size alone. `minHeight` reserves full 2-line space even
                    // for a 1-line title, so every card in the grid is still
                    // the same height regardless of how many lines its own
                    // title actually needs.
                    Text(card.gridTitle)
                        .font(.hepSectionHeading)
                        .foregroundStyle(Color.hepInk)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: 36, alignment: .topLeading)
                    // Always renders — blank when there's no subtitle —
                    // so every card reserves the same height whether or not
                    // it has one, keeping every tile in the two-column grid
                    // the same size, not just the same width.
                    Text(card.subtitle ?? " ")
                        .font(.hepSubtitle)
                        .foregroundStyle(card.subtitle == nil ? .clear : Color.hepMuted)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                if let badgeTier {
                    doneBadge(tier: badgeTier)
                }
            }
            .frame(minHeight: Self.contentHeight)
        }
    }

    /// A small solid circle with a white checkmark, shown for a card marked
    /// `done` or `reviewed` (verified on-device). Tier-driven so `reviewed`
    /// can render as its own distinct color (`Tier.urg`, amber) instead of
    /// colliding with `done`'s green.
    private func doneBadge(tier: Tier) -> some View {
        Image(systemName: "checkmark")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(tier.onSolid)
            .frame(width: 16, height: 16)
            .background(tier.solid, in: Circle())
    }
}
