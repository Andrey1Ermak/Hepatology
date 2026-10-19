import SwiftUI

/// The shared "this is a distinct block" container — every standard block,
/// pathway node, and calculator wraps its content in this, so a card detail
/// screen reads as a sequence of clearly separated sections. Styled as the
/// lesson decks' cards (CLAUDE.md §12.3): a pale tint fill for the block's
/// meaning, an optional 4 pt saturated stripe across the top, a soft shadow
/// and no outline.
struct SectionCard<Content: View>: View {
    var background: Color = Color.hepSurface
    /// The saturated top stripe (a block's or a pathway arm's tier color,
    /// navy for a neutral block) — omitted when nil, e.g. for a box nested
    /// inside an already-striped arm, where a second stripe would be noise.
    var stripe: Color? = nil
    @ViewBuilder var content: () -> Content

    /// Height of the top stripe — §12.3.
    static var stripeHeight: CGFloat { 4 }

    var body: some View {
        content()
            .padding(Spacing.m)
            .padding(.top, stripe == nil ? 0 : Self.stripeHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .overlay(alignment: .top) {
                if let stripe {
                    stripe.frame(height: Self.stripeHeight)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
            .hepElevated()
    }
}

#Preview {
    VStack(spacing: 12) {
        SectionCard { Text("Plain section card") }
        SectionCard(background: Tier.crit.tint, stripe: Tier.crit.solid) {
            Text("Red-flag block")
        }
        SectionCard(stripe: Color.hepNavy) { Text("Neutral block") }
    }
    .padding()
}
