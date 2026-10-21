import XCTest
@testable import HepReference

final class CardSourcesTests: XCTestCase {
    private let registry = [
        Guideline(id: "nc_2017", title: "", society: "NASPGHAN/ESPGHAN", year: 2017, citation: "", url: nil, checked: "2026-10", supersedes: nil),
        Guideline(id: "aap_2022", title: "", society: "AAP", year: 2022, citation: "", url: nil, checked: "2026-09", supersedes: nil),
        Guideline(id: "nc_2017_b", title: "", society: "NASPGHAN/ESPGHAN", year: 2017, citation: "", url: nil, checked: "2026-11", supersedes: nil),
    ]

    private func card(code: String = "Hand-written", guidelines: [String]?) -> Card {
        Card(id: "c", title: "C", code: code, cat: .jaundice, acu: .urg, guidelines: guidelines)
    }

    func testSourceLineComesFromTheRegistryInCardOrder() {
        XCTAssertEqual(card(guidelines: ["aap_2022", "nc_2017"]).sourceLine(in: registry), "AAP 2022 · NASPGHAN/ESPGHAN 2017")
    }

    func testSameSocietyAndYearIsShownOnce() {
        XCTAssertEqual(card(guidelines: ["nc_2017", "nc_2017_b"]).sourceLine(in: registry), "NASPGHAN/ESPGHAN 2017")
    }

    func testSourceLineFallsBackToCode() {
        XCTAssertEqual(card(guidelines: nil).sourceLine(in: registry), "Hand-written")
        XCTAssertEqual(card(guidelines: ["unknown"]).sourceLine(in: registry), "Hand-written")
        XCTAssertNil(card(code: "  ", guidelines: nil).sourceLine(in: registry))
    }

    func testCheckedIsTheOldestSourceMonth() {
        XCTAssertEqual(card(guidelines: ["nc_2017", "aap_2022", "nc_2017_b"]).checkedLabel(in: registry), "Checked 09/2026")
    }

    func testCheckedIsAbsentWithoutSourcesOrWithABadDate() {
        XCTAssertNil(card(guidelines: nil).checkedLabel(in: registry))
        let bad = [Guideline(id: "x", title: "", society: "S", year: 2020, citation: "", url: nil, checked: "Oct 2026", supersedes: nil)]
        XCTAssertNil(card(guidelines: ["x"]).checkedLabel(in: bad))
    }

    func testStudyDaysNameTheTopicWhenKnown() throws {
        let plan = try JSONDecoder().decode([PlanBlock].self, from: Data(#"[{"block":2,"title":"T","start":"2026-10-12","days":[{"day":1,"topic":"Definitions","cards":[]}]}]"#.utf8))
        let card = Card(id: "c", title: "C", code: "", cat: .jaundice, acu: .urg, plan: [PlanRef(block: 2, days: [1, 3]), PlanRef(block: 9, days: [2])])
        XCTAssertEqual(card.studyDays(in: plan), ["Block 2 · Day 1 — Definitions", "Block 2 · Day 3", "Block 9 · Day 2"])
        XCTAssertEqual(Card(id: "d", title: "D", code: "", cat: .ref, acu: .ref).studyDays(in: plan), [])
    }

    func testAgeLabelsMatchTheBands() {
        XCTAssertEqual(AgeBand.allCases.map(\.label), ["0–28 d", "1–12 mo", "1–10 y", "11–18 y"])
    }
}
