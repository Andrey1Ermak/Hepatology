import XCTest
@testable import HepReference

/// Engine-level tests for the declarative calculator kinds, using inline
/// fixtures so they never depend on which clinical content is bundled.
/// Clinical calculators get their own reference-vector tests.
final class RuleEngineTests: XCTestCase {
    private func screen(_ json: String) throws -> ChipScreen {
        try JSONDecoder().decode(ChipScreen.self, from: Data(json.utf8))
    }

    func testChecklistAnyFirstMatchingTierWins() throws {
        let s = try screen("""
        {"id":"x","rows":[{"items":[{"key":"a","label":"A"},{"key":"b","label":"B"}]}],
         "rule":{"kind":"checklist_any","tiers":[{"band":"hi","keys":["a","b"],"text":"{n} flag{s}"}],
                 "noneBand":"lo","noneText":"none"}}
        """)
        XCTAssertEqual(s.verdictRule.verdict(selected: []), Verdict(band: .lo, text: "none"))
        XCTAssertEqual(s.verdictRule.verdict(selected: ["a"]), Verdict(band: .hi, text: "1 flag"))
        XCTAssertEqual(s.verdictRule.verdict(selected: ["a", "b"]), Verdict(band: .hi, text: "2 flags"))
    }

    func testChipScoreSumsWeightedPoints() throws {
        let s = try screen("""
        {"id":"x","rows":[{"items":[{"key":"a","label":"A"},{"key":"b","label":"B"}]}],
         "rule":{"kind":"chip_score","points":{"a":1,"b":2},
                 "bands":[{"min_score":3,"band":"hi","text":"Score {n}"},{"min_score":0,"band":"lo","text":"Score {n}"}]}}
        """)
        XCTAssertEqual(s.verdictRule.verdict(selected: ["b"]), Verdict(band: .lo, text: "Score 2"))
        XCTAssertEqual(s.verdictRule.verdict(selected: ["a", "b"]), Verdict(band: .hi, text: "Score 3"))
    }

    func testChipCountSpecialKeyOverridesCount() throws {
        let s = try screen("""
        {"id":"x","rows":[{"items":[{"key":"a","label":"A"},{"key":"z","label":"Z"}]}],
         "rule":{"kind":"chip_count","special_key":"z","special_band":"hi","special_text":"special",
                 "thresholds":[{"min_count":2,"band":"mid","text":"{n}"},{"min_count":0,"band":"lo","text":"{n}"}]}}
        """)
        XCTAssertEqual(s.verdictRule.verdict(selected: ["a"]).band, .lo)
        XCTAssertEqual(s.verdictRule.verdict(selected: ["z"]), Verdict(band: .hi, text: "special"))
    }

    func testChipTierHighestTierAndOverride() throws {
        let s = try screen("""
        {"id":"x","rows":[{"items":[{"key":"a","label":"A"},{"key":"b","label":"B"},{"key":"o","label":"O"}]}],
         "rule":{"kind":"chip_tier","tiers":[{"key":"t1","items":["a"],"band":"lo","text":"mild"},
                                              {"key":"t2","items":["b"],"band":"hi","text":"severe"}],
                 "override":{"items":["o"],"band":"mid","text":"other"},"noneBand":"lo","noneText":"none"}}
        """)
        XCTAssertEqual(s.verdictRule.verdict(selected: ["a", "b"]).text, "severe")
        XCTAssertEqual(s.verdictRule.verdict(selected: ["a", "o"]).text, "other")
        XCTAssertEqual(s.verdictRule.verdict(selected: []).text, "none")
    }

    func testScoreCalcBandsAndConditionalOptions() throws {
        let schema = try JSONDecoder().decode(ScoreCalcSchema.self, from: Data("""
        {"id":"x","max_score":4,
         "dimensions":[
           {"key":"age","label":"Age","scored":false,"default":"young","options":[{"value":"young","label":"<1 y"},{"value":"old","label":"≥1 y"}]},
           {"key":"s","label":"Sign","conditional_options":[
             {"whenKey":"age","whenValue":"young","options":[{"value":"0","label":"no"},{"value":"2","label":"yes"}]},
             {"whenKey":"age","whenValue":"old","options":[{"value":"0","label":"no"},{"value":"4","label":"yes"}]}]}],
         "bands":[{"min":3,"band":"hi","label":"High","tier":"t"},{"min":0,"band":"lo","label":"Low","tier":"t"}]}
        """.utf8))
        XCTAssertEqual(schema.dimensions[1].resolvedOptions(selections: ["age": "old"]).last?.value, "4")
        XCTAssertEqual(schema.band(for: 4)?.label, "High")
        XCTAssertEqual(schema.band(for: 2)?.label, "Low")
    }
}
