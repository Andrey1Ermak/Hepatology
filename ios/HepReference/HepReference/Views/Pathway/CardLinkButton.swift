import SwiftUI

/// A pathway step's hand-off to another card (`link_card_id`). Pushes the
/// target onto the enclosing `NavigationStack`, whose `String` destination
/// already resolves card ids (Browse and Search both register one).
///
/// Deliberately the inverse of the solid navy "Calculate" capsule: an
/// outlined capsule on `hepCard` with navy text and a trailing arrow, so a
/// fellow can tell "open a calculator over this card" from "leave for
/// another card" at a glance. Shows the target's `gridTitle` (the Browse
/// tile name, ≤ 25 characters), wrapping to a second line at large text.
struct CardLinkButton: View {
    let cardId: String
    @Environment(CardLibrary.self) private var library: CardLibrary?

    private var target: Card? { library?.cardsByID[cardId] }

    var body: some View {
        NavigationLink(value: cardId) {
            HStack(spacing: 3) {
                Text(target?.gridTitle ?? "Open card")
                Image(systemName: "arrow.right")
            }
            .font(.hepTag)
            .foregroundStyle(Color.hepNavy)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 3)
            .background(Color.hepCard, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.hepNavy, lineWidth: 1))
            // Tap area grows to the 44 pt minimum without growing the capsule.
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open card: \(target?.title ?? cardId)")
        .accessibilityHint("Opens another card")
    }
}
