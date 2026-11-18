import XCTest
@testable import HepReference

/// The end-to-end scenarios of CLAUDE.md §4.6, walked over the real link
/// graph: a scenario starts on a card reachable from the home screen and
/// every step must be something the fellow can actually tap or read from
/// where they stand.
///
/// A `.card` step follows what the card shows as tappable going forward —
/// pathway `link_card_id`s and `related` (both in `LinkIndex.next`/`refs`);
/// "Linked from" is not a forward step, use `.back`. A `.calc` keeps the
/// fellow on the card, so a calculator on an earlier card needs a `.back`
/// first (scenario 3: ref F → `.back` → `nac`). After an `.age` step the
/// fellow sees only that `age_switch` branch, so `.card`, `.calc` and
/// `.outcome` must come from that branch's pathway (`.card` may also open
/// a reference card from the Links footer, `.calc` a calculator block on
/// the card itself).
struct Scenario {
    enum Step: Equatable {
        /// Open a card linked from the current one (pathway `link_card_id`,
        /// `related`, or a reference card).
        case card(String)
        /// Open a calculator from the current card (pathway link,
        /// `numeric_calc`, inline `chip_screen` or `score_calc`). The
        /// fellow stays on the card.
        case calc(String)
        /// Choose an `age_switch` option (by `age`) on the current card.
        case age(AgeBand)
        /// The current card has a First contact (`workup`) block.
        case workup
        /// Some pathway outcome in view — inside the arm tagged `arm`, when
        /// given — whose condition, pills or subtext contain `text`
        /// (case-insensitive).
        case outcome(String, arm: String? = nil)
        /// Go back to the previous card.
        case back
    }

    let name: String
    let start: String
    let steps: [Step]

    private struct Frame {
        let card: String
        /// The chosen `age_switch` branch's pathway, once an `.age` step ran.
        var pathId: String?
    }

    /// Every step that cannot be taken, as a message; empty when the walk
    /// completes. Stops at the first broken step — later ones would only
    /// report its consequences.
    func violations(
        cardsByID: [String: Card], homeCardIDs: Set<String>, links: LinkIndex,
        pathway: (String) -> Pathway? = { _ in nil }
    ) -> [String] {
        guard homeCardIDs.contains(start), cardsByID[start] != nil else {
            return ["\(name): start '\(start)' is not on the home screen"]
        }
        var stack = [Frame(card: start)]
        for (i, step) in steps.enumerated() {
            let frame = stack[stack.count - 1]
            let current = frame.card
            let card = cardsByID[current]
            let here = links.links(for: current)
            let branch = frame.pathId.flatMap(pathway)
            let inView = branch.map { [$0] } ?? (card?.pathIds.compactMap(pathway) ?? [])
            let location = "\(name), step \(i + 1) on '\(current)'"
            switch step {
            case .card(let id):
                // The Links footer (refs) stays visible whatever age is chosen.
                let tappable = branch.map { $0.cardLinks + here.refs } ?? (here.next + here.refs)
                guard tappable.contains(id), cardsByID[id] != nil else {
                    return ["\(location): no link to card '\(id)'"]
                }
                stack.append(Frame(card: id))
            case .calc(let id):
                let blockCalcs = card?.blocks.compactMap { block -> String? in
                    switch block {
                    case .chipScreen(let b): b.calcId
                    case .scoreCalc(let b): b.calcId
                    case .numericCalc(let b): b.calcId
                    default: nil
                    }
                } ?? []
                let pathCalcs = branch.map(\.calcLinks) ?? here.calcs.map(\.id)
                guard pathCalcs.contains(id) || blockCalcs.contains(id) else {
                    return ["\(location): no calculator '\(id)'"]
                }
            case .age(let age):
                let options = card?.blocks.flatMap { block -> [AgeSwitchOption] in
                    if case .ageSwitch(let b) = block { return b.options }
                    return []
                } ?? []
                guard let option = options.first(where: { $0.age == age }), pathway(option.pathId) != nil else {
                    return ["\(location): no age branch '\(age.rawValue)'"]
                }
                stack[stack.count - 1].pathId = option.pathId
            case .workup:
                let has = card?.blocks.contains { if case .workup = $0 { true } else { false } } ?? false
                guard has else { return ["\(location): no First contact block"] }
            case .outcome(let text, let arm):
                let needle = text.lowercased()
                let found = inView.flatMap { $0.children.flatMap { $0.outcomeTexts(arm: nil) } }.contains {
                    (arm == nil || $0.arm == arm) && $0.text.lowercased().contains(needle)
                }
                guard found else {
                    return ["\(location): no outcome '\(text)'" + (arm.map { " in arm '\($0)'" } ?? "")]
                }
            case .back:
                guard stack.count > 1 else { return ["\(location): nothing to go back to"] }
                stack.removeLast()
            }
        }
        return []
    }
}

private extension PathwayNode {
    /// Every `out` below this node as one searchable string (condition,
    /// pills, subtext), tagged with the nearest enclosing arm.
    func outcomeTexts(arm: String?) -> [(arm: String?, text: String)] {
        switch self {
        case .out(let condition, let pills, let subtext, _, _, _, _):
            let text = ([condition] + pills.map(\.text) + [subtext]).compactMap { $0 }.joined(separator: " · ")
            return [(arm, text)]
        case .arm(_, let tag, _, let children):
            return children.flatMap { $0.outcomeTexts(arm: tag) }
        default:
            return children.flatMap { $0.outcomeTexts(arm: arm) }
        }
    }
}

final class ScenarioTests: XCTestCase {
    /// §4.6 acceptance scenarios. Empty until their cards exist — add each
    /// one in the release that ships its last card (scenario 1 → v0.1,
    /// scenario 3 → v0.4, scenario 2 → v0.5).
    static let scenarios: [Scenario] = [
        // 1 · Night call: 5 weeks, jaundice, pale stool → chol_0_3m → 1–3
        // month branch → (INR 2.4) → inr_prolonged → back → First contact →
        // Kasai clock → pale stools: call surgery today → high probability
        // of atresia (high GGT, triangular cord): cholangiogram + Kasai.
        Scenario(name: "Scenario 1 · night call", start: "chol_0_3m", steps: [
            .age(.infant),
            .outcome("INR prolonged"), .card("inr_prolonged"), .back,
            .workup,
            .calc("c_kasai_clock"),
            .outcome("surgery today"),
            .outcome("Kasai", arm: "High probability of atresia"),
        ]),
    ]

    func testEveryScenarioWalksOverRealLinks() {
        let bundle = Bundle(for: ScenarioTests.self)
        let library = CardLibrary(bundle: bundle)
        XCTAssertFalse(library.cardsByID.isEmpty, "bundled library failed to load")
        let homeCardIDs = ContentGate.homeCardIDs(library.homeSections)
        for scenario in Self.scenarios {
            for violation in scenario.violations(
                cardsByID: library.cardsByID, homeCardIDs: homeCardIDs, links: library.links,
                pathway: { Pathway.load(pathId: $0, bundle: bundle) }
            ) {
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

    func testAgeBranchLimitsLinksAndOutcomes() throws {
        let neo = try JSONDecoder().decode(Pathway.self, from: Data(#"""
        {"id":"p_neo","children":[
          {"t":"arm","kind":"sev","tag":"Sick","children":[
            {"t":"out","cond":"Bleeding","pill":{"kind":"picu","text":"Vitamin K now"},"link_card_id":"b"}]}
        ]}
        """#.utf8))
        let infant = try JSONDecoder().decode(Pathway.self, from: Data(#"""
        {"id":"p_inf","children":[
          {"t":"out","cond":"Pale stool","subtext":"Call surgery today","link_calc_id":"c_kasai_clock"}
        ]}
        """#.utf8))
        let pathways = ["p_neo": neo, "p_inf": infant]
        let cards = [
            try card("a", blocks: #"""
            [{"t":"age_switch","options":[{"age":"neo","label":"0–28 d","path_id":"p_neo"},
                                          {"age":"infant","label":"1–3 mo","path_id":"p_inf"}]},
             {"t":"workup","groups":[{"label":"Blood","items":["INR"]}]}]
            """#),
            try card("b"),
        ]
        let links = LinkIndex(cards: cards, pathway: { pathways[$0] })
        let byID = Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0) })
        func walk(_ steps: [Scenario.Step]) -> [String] {
            Scenario(name: "s", start: "a", steps: steps)
                .violations(cardsByID: byID, homeCardIDs: ["a"], links: links, pathway: { pathways[$0] })
        }
        XCTAssertEqual(walk([.age(.neo), .outcome("vitamin k", arm: "Sick"), .card("b"), .back, .workup]), [])
        XCTAssertEqual(walk([.age(.infant), .calc("c_kasai_clock"), .outcome("surgery today")]), [])
        // Without an age choice the whole card is in view.
        XCTAssertEqual(walk([.card("b"), .back, .outcome("surgery today")]), [])
        XCTAssertEqual(walk([.age(.infant), .card("b")]), ["s, step 2 on 'a': no link to card 'b'"])
        XCTAssertEqual(walk([.age(.neo), .outcome("surgery today")]), ["s, step 2 on 'a': no outcome 'surgery today'"])
        XCTAssertEqual(walk([.outcome("Vitamin K", arm: "Well")]), ["s, step 1 on 'a': no outcome 'Vitamin K' in arm 'Well'"])
        XCTAssertEqual(walk([.age(.teen)]), ["s, step 1 on 'a': no age branch 'teen'"])
        XCTAssertEqual(walk([.card("b"), .workup]), ["s, step 2 on 'b': no First contact block"])
    }
}
