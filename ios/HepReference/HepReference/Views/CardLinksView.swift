import SwiftUI

/// The card's automatic last section, "Links" (CLAUDE.md §3.3, row 10):
/// Next steps · Reference · Calculators · Study · Linked from. Nothing here
/// is authored on the card — it comes from `LinkIndex` and the year plan,
/// so a link added anywhere shows up on both ends. Hidden when empty.
struct CardLinksView: View {
    let card: Card
    @Environment(CardLibrary.self) private var library: CardLibrary?
    @Environment(Registry.self) private var registry: Registry?
    @EnvironmentObject private var calculatorPresenter: CalculatorPresenter

    private var links: CardLinks { library?.links.links(for: card.id) ?? CardLinks() }

    /// Only Swift calculators open from here; anything else a pathway links
    /// to is reached from its own step.
    private var calcs: [CalcRef] { links.calcs.filter { NumericCalcRegistry.ids.contains($0.id) } }

    private var studyDays: [String] { card.studyDays(in: registry?.plan ?? []) }

    /// A card already listed above as a target isn't repeated here.
    private var linkedFrom: [String] {
        links.linkedFrom.filter { !links.next.contains($0) && !links.refs.contains($0) }
    }

    var body: some View {
        if !links.isEmpty || !studyDays.isEmpty {
            CollapsibleSection(title: "Links", background: Color.hepSurface, stripe: Color.hepNavy) {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    cardGroup("Next steps", links.next)
                    cardGroup("Reference", links.refs)
                    if !calcs.isEmpty {
                        group("Calculators") {
                            ForEach(calcs, id: \.id) { calc in
                                Button {
                                    calculatorPresenter.present(calcId: calc.id, title: calc.label ?? calc.id)
                                } label: {
                                    linkRow(calc.label ?? calc.id, icon: "function")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    if !studyDays.isEmpty {
                        group("Study") {
                            ForEach(studyDays, id: \.self) { day in
                                RowView(label: nil, text: day)
                            }
                        }
                    }
                    cardGroup("Linked from", linkedFrom)
                }
            }
        }
    }

    @ViewBuilder
    private func cardGroup(_ title: String, _ ids: [String]) -> some View {
        let cards = ids.compactMap { library?.cardsByID[$0] }
        if !cards.isEmpty {
            group(title) {
                ForEach(cards) { target in
                    NavigationLink(value: target.id) {
                        linkRow(target.title, icon: "arrow.right")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.hepSectionHeading)
                .foregroundStyle(Color.hepInk)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }

    private func linkRow(_ text: String, icon: String) -> some View {
        HStack(spacing: Spacing.s) {
            Text(text)
                .font(.hepCaption)
                .foregroundStyle(Color.hepInk)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.s)
            Image(systemName: icon)
                .font(.hepIconSmall)
                .foregroundStyle(Color.hepNavy)
        }
        .padding(.vertical, Spacing.xs)
        .contentShape(Rectangle())
    }
}
