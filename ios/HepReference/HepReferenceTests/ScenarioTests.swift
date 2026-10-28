import XCTest
@testable import HepReference

/// The end-to-end scenarios of CLAUDE.md §4.6, walked over the real link
/// graph: a scenario starts on a card reachable from the home screen and
/// every step must be a link the fellow can actually tap from where they
/// stand. Scenarios are added as their cards ship (scenario 1 with v0.1).
///
/// A `.card` step follows what the card shows as tappable going forward —
/// pathway `link_card_id`s and `related` (both in `LinkIndex.next`/`refs`);
/// "Linked from" is not a forward step, use `.back`. A `.calc` keeps the
/// fellow on the card, so a calculator on an earlier card needs a `.back`
/// first (scenario 3: ref F → `.back` → `nac`). Age and branch choices are
/// not modeled yet: when scenarios need them, add an `.age` step that
/// limits links to that `age_switch` branch.
struct Scenario {
    enum Step: Equatable {
        /// Open a card linked from the current one (pathway `link_card_id`,
        /// `related`, or a reference card).
        case card(String)
        /// Open a calculator from the current card (pathway link,
        /// `numeric_calc`, inline `chip_screen` or `score_calc`). The
        /// fellow stays on the card.
        case calc(String)
        /// Go back to the previous card.
        case back
    }

    let name: String
    let start: String
    let steps: [Step]

    /// Every step that cannot be taken, as a message; empty when the walk
    /// completes. Stops at the first broken step — later ones would only
    /// report its consequences.
    func violations(cardsByID: [String: Card], homeCardIDs: Set<String>, links: LinkIndex) -> [String] {
        guard homeCardIDs.contains(start), cardsByID[start] != nil else {
            return ["\(name): start '\(start)' is not on the home screen"]
        }
        var stack = [start]
        for (i, step) in steps.enumerated() {
            let current = stack[stack.count - 1]
            let here = links.links(for: current)
            let location = "\(name), step \(i + 1) on '\(current)'"
            switch step {
            case .card(let id):
                guard (here.next + here.refs).contains(id), cardsByID[id] != nil else {
                    return ["\(location): no link to card '\(id)'"]
                }
                stack.append(id)
            case .calc(let id):
                let inline = cardsByID[current]?.blocks.compactMap { block -> String? in
                    switch block {
                    case .chipScreen(let b): b.calcId
                    case .scoreCalc(let b): b.calcId
                    default: nil
                    }
                } ?? []
                guard here.calcs.map(\.id).contains(id) || inline.contains(id) else {
                    return ["\(location): no calculator '\(id)'"]
                }
            case .back:
                guard stack.count > 1 else { return ["\(location): nothing to go back to"] }
                stack.removeLast()
            }
        }
        return []
    }
}

final class ScenarioTests: XCTestCase {
    /// §4.6 acceptance scenarios. Empty until their cards exist — add each
    /// one in the release that ships its last card (scenario 1 → v0.1,
    /// scenario 3 → v0.4, scenario 2 → v0.5).
    static let scenarios: [Scenario] = []

    func testEveryScenarioWalksOverRealLinks() {
        let library = CardLibrary(bundle: Bundle(for: ScenarioTests.self))
        XCTAssertFalse(library.cardsByID.isEmpty, "bundled library failed to load")
        let homeCardIDs = ContentGate.homeCardIDs(library.homeSections)
        for scenario in Self.scenarios {
            for violation in scenario.violations(cardsByID: library.cardsByID, homeCardIDs: homeCardIDs, links: library.links) {
                XCTFail(violation)
            }
        }
    }

    // MARK: The walker itself, on fixtures

    private func card(_ id: String, cat: CardCategory = .jaundice, related: [String]? = nil, blocks: String = "[]") throws -> Card {
        Card(id: id, title: id, code: "", cat: cat, acu: .urg, related: related,
             blocks: try JSONDecoder().decode([Block].self, from: Data(blocks.utf8)))
    }

    private func fixture() throws -> (cards: [String: Card], links: LinkIndex) {
        let pathway = try JSONDecoder().decode(Pathway.self, from: Data(#"""
        {"id":"p_a","children":[
          {"t":"out","cond":"INR high","subtext":"See","link_card_id":"b"},
          {"t":"row","text":"Age","link_calc_id":"c_kasai_clock"},
          {"t":"row","text":"Norms","link_card_id":"ref_x"}
        ]}
        """#.utf8))
        let cards = [
            try card("a", blocks: #"[{"t":"pathway","path_id":"p_a"},{"t":"chip_screen","calc_id":"c_inline"}]"#),
            try card("b", related: ["a"]),
            try card("ref_x", cat: .ref),
            try card("island"),
        ]
        let links = LinkIndex(cards: cards, pathway: { $0 == "p_a" ? pathway : nil })
        return (Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0) }), links)
    }

    func testWalkerFollowsCardsCalculatorsAndBack() throws {
        let f = try fixture()
        let scenario = Scenario(name: "ok", start: "a", steps: [
            .card("b"), .back, .calc("c_kasai_clock"), .calc("c_inline"), .card("ref_x"),
        ])
        XCTAssertEqual(scenario.violations(cardsByID: f.cards, homeCardIDs: ["a", "b"], links: f.links), [])
    }

    func testWalkerReportsTheFirstBrokenStep() throws {
        let f = try fixture()
        let home: Set<String> = ["a", "island"]
        XCTAssertEqual(
            Scenario(name: "s", start: "a", steps: [.card("island"), .card("b")])
                .violations(cardsByID: f.cards, homeCardIDs: home, links: f.links),
            ["s, step 1 on 'a': no link to card 'island'"]
        )
        XCTAssertEqual(
            Scenario(name: "s", start: "b", steps: []).violations(cardsByID: f.cards, homeCardIDs: home, links: f.links),
            ["s: start 'b' is not on the home screen"]
        )
        XCTAssertEqual(
            Scenario(name: "s", start: "a", steps: [.card("b"), .calc("c_kasai_clock")])
                .violations(cardsByID: f.cards, homeCardIDs: home, links: f.links),
            ["s, step 2 on 'b': no calculator 'c_kasai_clock'"]
        )
        XCTAssertEqual(
            Scenario(name: "s", start: "a", steps: [.back]).violations(cardsByID: f.cards, homeCardIDs: home, links: f.links),
            ["s, step 1 on 'a': nothing to go back to"]
        )
    }
}
