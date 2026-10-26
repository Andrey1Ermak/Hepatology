import SwiftUI

/// "Test yourself" (CLAUDE.md §3.3 row 9) — a Learn-layer section,
/// collapsed until tapped. Each case shows its stem and question; the
/// answer and the teaching point stay hidden until "Show answer", so the
/// fellow commits to an answer first. Reveals live in view state and reset
/// when the card is left. Cases come from `Registry/cases.json`.
struct CaseBlockView: View {
    let block: CaseBlock
    /// Injected by previews and the design sample; nil reads the app's registry.
    var cases: [ClinicalCase]?
    /// Open on appear, answers shown — the DEBUG design sample only.
    var startsExpanded = false
    var startsRevealed = false

    @Environment(Registry.self) private var registry: Registry?
    @State private var revealed: Set<String> = []

    private var items: [ClinicalCase] { block.clinicalCases(in: cases ?? registry?.cases ?? []) }

    var body: some View {
        let items = items
        // Unreachable in shipped content (the integrity gate requires every
        // case_id to resolve), but never render an empty section.
        if !items.isEmpty {
            CollapsibleSection(title: block.h ?? "Test yourself", startsExpanded: startsExpanded) {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        if index > 0 {
                            Rectangle()
                                .fill(Color.hepRule)
                                .frame(height: 0.5)
                                .accessibilityHidden(true)
                        }
                        caseView(item, number: index + 1)
                    }
                }
            }
            .onAppear { if startsRevealed { revealed = Set(items.map(\.id)) } }
        }
    }

    private func caseView(_ item: ClinicalCase, number: Int) -> some View {
        let isRevealed = revealed.contains(item.id)
        return VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Case \(number)")
                .hepKickerStyle()
                .accessibilityAddTraits(.isHeader)
            Text(CardMarkup.attributedString(item.stem))
                .font(.hepBody)
                .foregroundStyle(Color.hepInk)
            Text(CardMarkup.attributedString(item.question))
                .font(.hepBodyEmphasis)
                .foregroundStyle(Color.hepInk)
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isRevealed { revealed.remove(item.id) } else { revealed.insert(item.id) }
                }
            } label: {
                Label(isRevealed ? "Hide answer" : "Show answer", systemImage: isRevealed ? "eye.slash" : "eye")
                    .font(.hepTag)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.hepNavy)
            }
            .buttonStyle(.plain)
            // Unique per case, so the rotor does not list identical buttons.
            .accessibilityLabel(isRevealed ? "Hide answer to case \(number)" : "Show answer to case \(number)")
            if isRevealed {
                answer(item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func answer(_ item: ClinicalCase) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Answer")
                .font(.hepCaptionBold)
                .foregroundStyle(Color.hepNavy)
            Text(CardMarkup.attributedString(item.answer))
                .font(.hepBody)
                .foregroundStyle(Color.hepInk)
            if let teaching = item.teaching {
                // The take-home line, bold italic as in the lessons.
                Text(CardMarkup.attributedString(teaching))
                    .font(.hepTakeaway)
                    .foregroundStyle(Color.hepInk)
                    .padding(.top, Spacing.xs)
            }
        }
        .padding(Spacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Tier.ref.tint)
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
        .accessibilityElement(children: .combine)
    }
}
