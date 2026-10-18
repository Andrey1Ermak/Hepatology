import SwiftUI

/// The shared "this is a distinct block" container — every standard block,
/// pathway node, and calculator wraps its content in this, so a card detail screen reads as a sequence of clearly separated
/// sections instead of one undifferentiated scroll. Defaults to a muted
/// `blockTint` wash rather than a plain system surface, so every block reads
/// as a distinct colored section instead of bare text on the page
/// background — a tier-tinted `background` (crit/urg boxes, etc.) still
/// overrides this the same as before.
struct SectionCard<Content: View>: View {
    var background: Color = Color("blockTint")
    /// A colored leading bar (e.g. a pathway arm's severity tier) — omitted when nil.
    var accent: Color? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: Radius.large))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.large)
                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
            }
            .overlay(alignment: .leading) {
                if let accent {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(accent)
                        .frame(width: 3)
                        .padding(.vertical, Spacing.s)
                }
            }
            .hepElevated()
    }
}

#Preview {
    VStack(spacing: 12) {
        SectionCard { Text("Plain section card") }
        SectionCard(background: Tier.crit.tint, accent: Tier.crit.solid) {
            Text("Accented, tinted section card")
        }
    }
    .padding()
}
