import SwiftUI

/// The page title, styled as a lesson slide's title block (CLAUDE.md §12.3):
/// kicker (maroon category number + category in blue caps) → title in navy
/// Heavy caps → source line in italic with the oldest "Checked" month →
/// age chips and the editorial status → double rule. Deliberately not a
/// `SectionCard` — it is the page heading, not another block in the scroll.
/// Sits inside `CardDetailView`'s fixed header, which paints the background.
struct CardHeaderView: View {
    let card: Card
    @Environment(Registry.self) private var registry: Registry?

    private var guidelines: [Guideline] { registry?.guidelines ?? [] }

    /// "NASPGHAN/ESPGHAN 2017 · AAP 2022 · Checked 10/2026" — freshness
    /// stays visible (§3.2) on the same line as the sources it dates.
    private var sourceText: String? {
        let parts = [card.sourceLine(in: guidelines), card.checkedLabel(in: guidelines)].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            KickerLine(number: RomanNumeral.string(card.cat.number), text: card.cat.displayName)
            Text(card.title)
                .hepTitleStyle()
                .accessibilityAddTraits(.isHeader)
            if let sourceText {
                Text(sourceText)
                    .font(.hepSubtitle)
                    .foregroundStyle(Color.hepMuted)
            }
            metaRow
        }
        .padding(.vertical, Spacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Age chips (pale info tint) then the status badge. Draft shows too:
    /// in the header an unreviewed card should say so (§3.2 "freshness
    /// visible"); the card-list tile keeps hiding it (D-2026-10-20-1).
    @ViewBuilder
    private var metaRow: some View {
        let ages = card.ages ?? []
        if !ages.isEmpty || card.status != nil {
            FlowLayout(horizontalSpacing: Spacing.xs, verticalSpacing: Spacing.xs) {
                ForEach(ages, id: \.self) { age in
                    Badge(text: age.label, tier: .ref, style: .tint, uppercase: false)
                        .accessibilityLabel("Ages \(age.spokenLabel)")
                }
                if let status = card.status {
                    Badge(text: status.label, tier: status.tier)
                        .accessibilityLabel("Status: \(status.label)")
                }
            }
        }
    }
}

private extension CardStatus {
    /// Same colors as the card-list tile's check badge; draft is neutral gray.
    var tier: Tier? {
        switch self {
        case .draft: nil
        case .reviewed: .rt
        case .approved: .ref
        }
    }
}
