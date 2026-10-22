import Foundation

/// One card's place in the link graph — what it points to and what points
/// back at it. Feeds the automatic Links section (CLAUDE.md §3.3, row 10).
struct CardLinks: Equatable {
    /// Non-reference cards this card hands off to, in reading order.
    var next: [String] = []
    /// Reference cards (`cat: ref`) this card points to.
    var refs: [String] = []
    /// Calculators reached from pathway steps or `numeric_calc` blocks.
    /// `chip_screen` and `score_calc` blocks are left out: they already
    /// render inline in the card body.
    var calcs: [CalcRef] = []
    /// Cards that point to this one, in manifest order.
    var linkedFrom: [String] = []

    var isEmpty: Bool { next.isEmpty && refs.isEmpty && calcs.isEmpty && linkedFrom.isEmpty }
}

/// The whole library's link graph, built once from every card and the
/// pathways they show (every `age_switch` branch included). A card's
/// outgoing links are its pathways' `link_card_id`s first, then
/// `related`; each target appears once, the
/// card itself and ids with no bundled card never do (the integrity gate
/// forbids those anyway, this just keeps a bad build from rendering them).
struct LinkIndex {
    private var byCard: [String: CardLinks] = [:]

    /// `cards` in manifest order — that order becomes "Linked from" order.
    init(cards: [Card], pathway: (String) -> Pathway?) {
        let known = Dictionary(cards.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for card in cards {
            let pathways = card.pathIds.compactMap(pathway)
            var links = CardLinks()
            for id in (pathways.flatMap(\.cardLinks) + (card.related ?? [])).uniqued()
            where id != card.id {
                guard let target = known[id] else { continue }
                if target.cat == .ref { links.refs.append(id) } else { links.next.append(id) }
            }
            let blockCalcs = card.blocks.compactMap { block -> CalcRef? in
                if case .numericCalc(let b) = block { return CalcRef(id: b.calcId, label: b.label) }
                return nil
            }
            var seen: [String: Int] = [:]
            for ref in blockCalcs + pathways.flatMap(\.calcRefs) {
                if let i = seen[ref.id] {
                    // Keep the first position; fill in a label if the first mention had none.
                    if links.calcs[i].label == nil, ref.label != nil { links.calcs[i] = ref }
                } else {
                    seen[ref.id] = links.calcs.count
                    links.calcs.append(ref)
                }
            }
            // `linkedFrom` may already hold entries from cards read earlier.
            links.linkedFrom = byCard[card.id]?.linkedFrom ?? []
            byCard[card.id] = links
            for target in links.next + links.refs {
                byCard[target, default: CardLinks()].linkedFrom.append(card.id)
            }
        }
    }

    func links(for cardId: String) -> CardLinks {
        byCard[cardId] ?? CardLinks()
    }
}

private extension Array where Element: Hashable {
    /// Drops repeats, keeping each element's first position.
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
