import XCTest
@testable import HepReference

/// Proves each `ContentGate` rule catches what it should on fixtures — the
/// bundled content is still almost empty, so the integrity gate alone would
/// pass even if a rule were broken.
final class ContentGateTests: XCTestCase {
    private func blocks(_ json: String) throws -> [Block] {
        try JSONDecoder().decode([Block].self, from: Data(json.utf8))
    }

    private func card(_ id: String = "x", cat: CardCategory = .jaundice, entry: EntryPoint? = .symptom,
                      guidelines: [String]? = ["g"], plan: [PlanRef]? = [PlanRef(block: 2, days: [1])],
                      blocks json: String) throws -> Card {
        Card(id: id, title: id, code: "", cat: cat, acu: .urg, entry: entry,
             guidelines: guidelines, plan: plan, blocks: try blocks(json))
    }

    private let fullAnatomy = #"""
    [{"t":"note","k":"crit","h":"Red flags","text":"Acholic stools"},
     {"t":"age_switch","h":"Age","options":[{"age":"neo","label":"0–28 d","path_id":"p1"},{"age":"infant","label":"1–3 mo","path_id":"p2"}]},
     {"t":"workup","h":"First contact","groups":[{"label":"Blood","items":["INR"]}]},
     {"t":"lab_norms","analytes":["alt"]},
     {"t":"list","h":"Don't miss","items":["Sepsis"]},
     {"t":"text","h":"Why","text":"Mechanism"},
     {"t":"pearls","items":[{"k":"pearl","text":"P"}]},
     {"t":"guideline_compare","h":"Guidelines","rows":[{"topic":"T","positions":{"g":"Yes"},"verdict":"gap"}]},
     {"t":"case","case_ids":["x_c1"]}]
    """#

    // MARK: Anatomy

    func testFullAnatomyPasses() throws {
        XCTAssertEqual(ContentGate.anatomyViolations(of: try card(blocks: fullAnatomy)), [])
    }

    func testReferenceCardsAreFreeForm() throws {
        XCTAssertEqual(ContentGate.anatomyViolations(of: try card(cat: .ref, entry: .reference, guidelines: nil, plan: nil, blocks: "[]")), [])
        XCTAssertEqual(ContentGate.anatomyViolations(of: try card(cat: .ref, entry: nil, blocks: "[]")), [])
    }

    func testAlgorithmCardMustDeclareEntry() throws {
        XCTAssertEqual(ContentGate.anatomyViolations(of: try card(entry: nil, blocks: fullAnatomy)),
                       [#"x: algorithm card without "entry""#])
    }

    /// `entry: reference` must not switch the check off on a clinical card,
    /// nor a reference card claim a clinical entry.
    func testReferenceEntryBelongsToReferenceCardsOnly() throws {
        XCTAssertEqual(ContentGate.anatomyViolations(of: try card(entry: .reference, blocks: "[]")),
                       [#"x: entry "reference" on a jaundice card — only cat: ref cards are reference"#])
        XCTAssertEqual(ContentGate.anatomyViolations(of: try card(cat: .ref, entry: .lab, blocks: "[]")),
                       [#"x: reference card with entry "lab" — use "reference""#])
    }

    /// Further down the card a crit note is a warning and a chip_screen a
    /// calculator (c_vitk_inr after the workup) — neither is out of order.
    /// A curly apostrophe in "Don’t miss" still counts.
    func testCritNoteAndChipScreenBelowTheTopAreNotRedFlags() throws {
        XCTAssertEqual(ContentGate.anatomyViolations(of: try card(blocks: #"""
        [{"t":"chip_screen","calc_id":"c_palf"},
         {"t":"age_switch","options":[{"age":"neo","label":"0–28 d","path_id":"p1"},{"age":"infant","label":"1–3 mo","path_id":"p2"}]},
         {"t":"pathway","path_id":"p_shared"},
         {"t":"note","k":"crit","text":"Call pediatric surgery today"},
         {"t":"workup","groups":[{"label":"Blood","items":["INR"]}]},
         {"t":"chip_screen","calc_id":"c_vitk_inr"},
         {"t":"list","h":"Don’t miss","items":["Sepsis"]}]
        """#)), [])
    }

    func testPathwayOnlyCardPasses() throws {
        XCTAssertEqual(ContentGate.anatomyViolations(of: try card(blocks: #"""
        [{"t":"note","k":"crit","text":"Acholic stools"},
         {"t":"pathway","path_id":"p"},
         {"t":"workup","groups":[{"label":"Blood","items":["INR"]}]},
         {"t":"list","h":"Don't miss","items":["Sepsis"]}]
        """#)), [])
    }

    func testRedFlagsLowerDownDoNotCountAsTheFirstBlock() throws {
        XCTAssertEqual(ContentGate.anatomyViolations(of: try card(blocks: #"""
        [{"t":"pathway","path_id":"p"},
         {"t":"note","k":"crit","text":"Acholic stools"},
         {"t":"workup","groups":[{"label":"Blood","items":["INR"]}]},
         {"t":"list","h":"Don't miss","items":["Sepsis"]}]
        """#)), ["x: first block must be red flags (note k: crit or chip_screen)"])
    }

    func testMissingSectionsAndMetadataAreReported() throws {
        let violations = ContentGate.anatomyViolations(of: try card(
            guidelines: [], plan: nil,
            blocks: #"[{"t":"note","k":"warn","text":"Not a red flag"},{"t":"list","h":"Causes","items":["A"]}]"#
        ))
        XCTAssertEqual(violations, [
            "x: first block must be red flags (note k: crit or chip_screen)",
            "x: no algorithm (pathway or age_switch)",
            "x: no First contact block",
            "x: no Don't miss block",
            "x: cites no guideline",
            "x: no plan block",
        ])
    }

    func testSectionsOutOfOrderAreReported() throws {
        let violations = ContentGate.anatomyViolations(of: try card(blocks: #"""
        [{"t":"chip_screen","calc_id":"c"},
         {"t":"workup","groups":[{"label":"Blood","items":["INR"]}]},
         {"t":"pathway","path_id":"p"},
         {"t":"list","h":"Don't miss","items":["Sepsis"]},
         {"t":"pearls","items":[{"k":"pearl","text":"P"}]},
         {"t":"text","h":"Why","text":"Mechanism"}]
        """#))
        XCTAssertEqual(violations, [
            "x: Algorithm after First contact — order per §3.3",
            "x: Why after Pearls & pitfalls — order per §3.3",
        ])
    }

    // MARK: Dead ends

    func testOutcomeWithoutActionIsADeadEnd() throws {
        let pathway = try JSONDecoder().decode(Pathway.self, from: Data(#"""
        {"id":"p","children":[{"t":"section","h":"S","children":[
          {"t":"arm","kind":"sev","tag":"Severe","children":[
            {"t":"out","cond":"Nowhere"},
            {"t":"out","cond":"Blank subtext","subtext":"  "}]},
          {"t":"out","cond":"Pill","pill":{"kind":"picu","text":"Call transplant center"}},
          {"t":"out","cond":"Subtext","subtext":"Repeat in 2 weeks"},
          {"t":"out","cond":"Card","link_card_id":"palf"},
          {"t":"out","cond":"Calc","link_calc_id":"nac"},
          {"t":"out","cond":"Empty pill","pills":[{"kind":"dc","text":" "}]}]}]}
        """#.utf8))
        XCTAssertEqual(ContentGate.deadEnds(in: pathway), [
            "p: outcome 'Nowhere' is a dead end — add a pill, subtext, link_card_id or link_calc_id",
            "p: outcome 'Blank subtext' is a dead end — add a pill, subtext, link_card_id or link_calc_id",
            "p: outcome 'Empty pill' has a pill without text",
        ])
    }

    // MARK: Reachability

    func testCardOnNoHomeTileIsUnreachable() throws {
        let cards = [
            "a": try card("a", blocks: "[]"),
            "about": try card("about", cat: .ref, entry: .reference, blocks: "[]"),
            "orphan": try card("orphan", blocks: "[]"),
        ]
        let manifest = [
            ManifestEntry(id: "a", cat: .jaundice, section: "J"),
            ManifestEntry(id: "about", cat: .ref, section: "R"),
        ]
        XCTAssertEqual(ContentGate.unreachableCards(manifestEntries: manifest, cardsByID: cards),
                       ["orphan: not reachable from the home screen in two steps"])
    }

    // MARK: Freshness

    func testOnlyChecksOlderThanTwelveMonthsWarn() throws {
        func g(_ id: String, _ checked: String) -> Guideline {
            Guideline(id: id, title: id, society: "S", year: 2020, citation: "C", url: nil, checked: checked, supersedes: nil)
        }
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-10-28T12:00:00Z"))
        XCTAssertEqual(
            ContentGate.staleGuidelines([g("fresh", "2026-10"), g("edge", "2025-10"), g("old", "2025-09")], now: now),
            ["old: checked 2025-09, 13 months ago — look for a newer version"]
        )
        let january = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-01-15T12:00:00Z"))
        XCTAssertEqual(
            ContentGate.staleGuidelines([g("edge", "2025-01"), g("old", "2024-12")], now: january),
            ["old: checked 2024-12, 13 months ago — look for a newer version"]
        )
    }
}
