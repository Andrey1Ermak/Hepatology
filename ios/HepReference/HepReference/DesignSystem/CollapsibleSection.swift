import SwiftUI

/// A tap-to-expand/collapse `SectionCard` — shared by every pathway
/// `.section` (see `PathwayNodeView`) and every inline calculator's header
/// (`ChipBoardView`/`ScoreCalcView`), so a card detail
/// screen reads as a deck of named sub-cards instead of one long scroll:
/// only the title is visible until tapped, and tapping again collapses it
/// back. Starts collapsed — a deliberate choice even for safety-critical
/// content like a red-flags section, confirmed on review.
struct CollapsibleSection<Content: View>: View {
    let title: String
    var background: Color = Color.hepSurface
    /// Top stripe color — navy (a neutral block) unless the caller passes
    /// the tier of what's inside.
    var stripe: Color = Color.hepNavy
    @State private var isExpanded: Bool
    @ViewBuilder var content: () -> Content

    /// Collapsed is the default; only the DEBUG design sample passes
    /// `startsExpanded` (for screenshots).
    init(
        title: String,
        background: Color = Color.hepSurface,
        stripe: Color = Color.hepNavy,
        startsExpanded: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.background = background
        self.stripe = stripe
        self._isExpanded = State(initialValue: startsExpanded)
        self.content = content
    }

    var body: some View {
        SectionCard(background: background, stripe: stripe) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                header
                if isExpanded {
                    content()
                }
            }
            // Matches `CardRowView.contentHeight` — collapsed, this is just
            // the header row, and a "deck" of collapsed sub-cards should
            // read as the same size as the Browse tiles it echoes, not a
            // thin strip. `.leading` (vertically centered), not `.topLeading`
            // — collapsed, the header should sit centered in that taller
            // frame, not stuck to its top edge. Harmless once expanded: real
            // content is already taller than this floor in every case, so
            // there's no extra space left to center within.
            .frame(minHeight: CardRowView.contentHeight, alignment: .leading)
        }
    }

    private var header: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
        } label: {
            HStack {
                Text(title)
                    .font(.hepSectionHeading)
                    .foregroundStyle(Color.hepInk)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.hepIconSmall)
                    .foregroundStyle(Color.hepNavy)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
    }
}
