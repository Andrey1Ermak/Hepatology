import SwiftUI

/// The star beside a card's title: adds the card to Home's Favorites or
/// removes it. Navy like the back button opposite it; a 44 pt target.
struct FavoriteButton: View {
    let cardID: String
    @Environment(CardHistory.self) private var history: CardHistory?

    var body: some View {
        if let history {
            let isFavorite = history.isFavorite(cardID)
            Button {
                history.toggleFavorite(cardID)
            } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.hepBodyEmphasis)
                    .imageScale(.large)
                    .foregroundStyle(Color.hepNavy)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // A fixed label; VoiceOver adds "Selected" when starred.
            .accessibilityLabel("Favorite")
            .accessibilityAddTraits(isFavorite ? .isSelected : [])
            .sensoryFeedback(.selection, trigger: isFavorite)
        }
    }
}
