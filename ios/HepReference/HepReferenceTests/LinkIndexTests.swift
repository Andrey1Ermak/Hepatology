import XCTest
@testable import HepReference

final class LinkIndexTests: XCTestCase {
    private func card(_ id: String, cat: CardCategory = .jaundice, related: [String]? = nil, blocks: String = "[]") throws -> Card {
        let blocks = try JSONDecoder().decode([Block].self, from: Data(blocks.utf8))
        return Card(id: id, title: id, code: "", cat: cat, acu: .urg, related: related, blocks: blocks)
    }

    private func pathway(_ json: String) throws -> Pathway {
        try JSONDecoder().decode(Pathway.self, from: Data(json.utf8))
    }

    func testOutgoingSplitsNextAndReferenceInReadingOrder() throws {
        let p = try pathway(#"""
        {"id":"p_a","children":[{"t":"section","h":"S","children":[
          {"t":"out","cond":"INR high","subtext":"See","link_card_id":"inr_prolonged"},
          {"t":"row","text":"Norms","link_card_id":"ref_norms"},
          {"t":"row","text":"Again","link_card_id":"inr_prolonged"},
          {"t":"row","text":"Self","link_card_id":"a"}
        ]}]}
        """#)
        let cards = [
            try card("a", related: ["chol_3_12m", "inr_prolonged"], blocks: #"[{"t":"pathway","path_id":"p_a"}]"#),
            try card("inr_prolonged", cat: .labs),
            try card("ref_norms", cat: .ref),
            try card("chol_3_12m"),
        ]
        let index = LinkIndex(cards: cards, pathway: { $0 == "p_a" ? p : nil })
        let links = index.links(for: "a")
        XCTAssertEqual(links.next, ["inr_prolonged", "chol_3_12m"])
        XCTAssertEqual(links.refs, ["ref_norms"])
    }

    func testLinkedFromIsTheReverseInCardOrder() throws {
        let cards = [
            try card("x", related: ["target"]),
            try card("target", related: ["x"]),
            try card("y", related: ["target"]),
        ]
        let index = LinkIndex(cards: cards, pathway: { _ in nil })
        XCTAssertEqual(index.links(for: "target").linkedFrom, ["x", "y"])
        XCTAssertEqual(index.links(for: "target").next, ["x"])
        XCTAssertEqual(index.links(for: "x").linkedFrom, ["target"])
        XCTAssertEqual(index.links(for: "y").linkedFrom, [])
    }

    func testUnknownTargetsAreDropped() throws {
        let index = LinkIndex(cards: [try card("a", related: ["not_written_yet"])], pathway: { _ in nil })
        XCTAssertTrue(index.links(for: "a").isEmpty)
        XCTAssertTrue(index.links(for: "not_written_yet").isEmpty)
    }

    func testCalculatorsFromBlocksAndPathwayStepsOnceEach() throws {
        let p = try pathway(#"""
        {"id":"p_c","children":[
          {"t":"row","text":"Dose","link_calc_id":"nac"},
          {"t":"out","cond":"Age","link_calc_id":"c_kasai_clock","link_label":"Kasai clock"},
          {"t":"row","text":"Again","link_calc_id":"c_kasai_clock","link_label":"Other label"}
        ]}
        """#)
        let c = try card("c", blocks: #"""
        [{"t":"numeric_calc","calc_id":"nac","label":"Acetaminophen NAC"},
         {"t":"chip_screen","calc_id":"c_palf"},
         {"t":"pathway","path_id":"p_c"}]
        """#)
        let index = LinkIndex(cards: [c], pathway: { $0 == "p_c" ? p : nil })
        XCTAssertEqual(index.links(for: "c").calcs, [
            CalcRef(id: "nac", label: "Acetaminophen NAC"),
            CalcRef(id: "c_kasai_clock", label: "Kasai clock"),
        ])
    }

    func testUnlabeledStepFallsBackToItsOwnText() throws {
        let p = try pathway(#"{"id":"p","children":[{"t":"out","cond":"Over 1000","link_calc_id":"c_rratio"},{"t":"row","text":"Dose it","link_calc_id":"nac"}]}"#)
        XCTAssertEqual(p.calcRefs, [CalcRef(id: "c_rratio", label: "Over 1000"), CalcRef(id: "nac", label: "Dose it")])
    }

    func testLaterLabelFillsAnUnlabeledFirstMention() throws {
        let p = try pathway(#"{"id":"p","children":[{"t":"row","text":"a","link_calc_id":"nac","link_label":"NAC"}]}"#)
        let c = try card("c", blocks: #"[{"t":"numeric_calc","calc_id":"nac"},{"t":"pathway","path_id":"p"}]"#)
        let index = LinkIndex(cards: [c], pathway: { _ in p })
        XCTAssertEqual(index.links(for: "c").calcs, [CalcRef(id: "nac", label: "NAC")])
    }

    func testBundledLibraryBuildsWithoutLosingCards() {
        let library = CardLibrary(bundle: Bundle(for: LinkIndexTests.self))
        XCTAssertFalse(library.cardsByID.isEmpty)
        for id in library.cardsByID.keys {
            let links = library.links.links(for: id)
            for target in links.next + links.refs + links.linkedFrom {
                XCTAssertNotNil(library.cardsByID[target], "\(id): link to unknown '\(target)'")
            }
        }
    }
}
