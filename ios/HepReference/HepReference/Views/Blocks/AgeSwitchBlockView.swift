import SwiftUI

/// Age chips over the algorithm (CLAUDE.md §3.3 row 2, §5.2): the selected
/// branch's pathway renders beneath them; the first branch shows until a
/// chip is tapped. The choice lives in the card's `CardSession`, so other
/// blocks can follow it; without one (design sample, previews) the view
/// keeps it locally.
struct AgeSwitchBlockView: View {
    let block: AgeSwitchBlock
    var loadPathway: (String) -> Pathway? = { Pathway.load(pathId: $0) }

    @Environment(CardSession.self) private var session: CardSession?
    @State private var localAge: AgeBand?

    private var chosenAge: AgeBand? { session?.age ?? localAge }

    var body: some View {
        let selected = block.option(for: chosenAge)
        VStack(alignment: .leading, spacing: Spacing.l) {
            SectionCard(stripe: Color.hepNavy) {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    BlockHeading(text: block.h)
                    FlowLayout {
                        ForEach(block.options, id: \.age) { option in
                            SelectableChip(label: option.label, isOn: option.age == selected?.age) {
                                select(option.age)
                            }
                        }
                    }
                    // VoiceOver hears the chips as one "Age" choice.
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(block.h ?? "Age")
                }
            }
            if let selected {
                Group {
                    if let pathway = loadPathway(selected.pathId) {
                        PathwayBlockView(pathway: pathway)
                    } else {
                        PlaceholderBlockView(kind: "Pathway", label: selected.pathId)
                    }
                }
                // A new branch starts with its own sections' default
                // expansion, not the previous branch's.
                .id(selected.pathId)
            }
        }
    }

    private func select(_ age: AgeBand) {
        if let session { session.age = age } else { localAge = age }
    }
}
