import XCTest
@testable import HepReference

final class RegistryDecodingTests: XCTestCase {
    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }

    func testGuideline() throws {
        let g = try decode([Guideline].self, #"""
        [{"id":"naspghan_espghan_2017_nc","title":"Guideline for the Evaluation of Cholestatic Jaundice in Infants",
          "society":"NASPGHAN/ESPGHAN","year":2017,"citation":"Fawaz R et al. JPGN 2017;64:154-168",
          "url":"https://example.org","checked":"2026-10","supersedes":null}]
        """#)
        XCTAssertEqual(g.first?.year, 2017)
        XCTAssertNil(g.first?.supersedes)
    }

    func testLabBandWithAndWithoutSex() throws {
        let labs = try decode([LabTest].self, #"""
        [{"id":"alt","name":"ALT","unit":"U/L","bands":[
          {"age":"child","sex":"F","high":22,"source":"safety_2010"},
          {"age":"infant","low":5,"high":40,"source":"x"}]}]
        """#)
        XCTAssertEqual(labs.first?.bands.first?.sex, .F)
        XCTAssertEqual(labs.first?.bands.first?.high, 22)
        XCTAssertNil(labs.first?.bands.last?.sex)
        XCTAssertEqual(labs.first?.bands.last?.low, 5)
    }

    private func band(_ json: String) throws -> LabBand {
        try decode(LabBand.self, json)
    }

    func testLabBandRangeText() throws {
        XCTAssertEqual(try band(#"{"age":"teen","high":22.1,"source":"s"}"#).rangeText, "≤ 22.1")
        XCTAssertEqual(try band(#"{"age":"teen","high":26,"source":"s"}"#).rangeText, "≤ 26")
        XCTAssertEqual(try band(#"{"age":"teen","low":7,"high":40,"source":"s"}"#).rangeText, "7–40")
        XCTAssertEqual(try band(#"{"age":"teen","low":150,"source":"s"}"#).rangeText, "≥ 150")
        XCTAssertEqual(try band(#"{"age":"neo","low":0.15,"high":1.25,"source":"s"}"#).rangeText, "0.15–1.25")
        XCTAssertEqual(try band(#"{"age":"neo","low":9120,"high":190546,"source":"s"}"#).rangeText, "9,120–190,546")
        XCTAssertEqual(try band(#"{"age":"neo","low":316,"high":1045.5,"source":"s"}"#).rangeText, "316–1,045.5")
        XCTAssertEqual(LabBand.parse(LabBand.format(1_234_567.25)), 1_234_567.25)
        XCTAssertEqual(LabBand.format(-123), "-123")
        XCTAssertEqual(LabBand.format(-123_456), "-123,456")
        XCTAssertEqual(LabBand.format(999), "999")
        XCTAssertNil(LabBand.parse("-,123"), "a misplaced separator must fail the gate")
        XCTAssertNil(LabBand.parse("12,34"))
        XCTAssertEqual(try band(#"{"age":"neo","low":9120,"high":190546,"source":"s"}"#).spokenRange, "9,120 to 190,546")
        XCTAssertEqual(try band(#"{"age":"neo","high":50,"source":"s"}"#).spokenRange, "up to 50")
    }

    func testLimitHeadingFollowsTheBands() throws {
        let labs = try decode([LabTest].self, #"""
        [{"id":"a","name":"A","unit":"U/L","bands":[{"age":"teen","high":22,"source":"s"}]},
         {"id":"b","name":"B","unit":"U/L","bands":[{"age":"teen","high":22,"source":"s"},{"age":"child","low":5,"high":40,"source":"s"}]}]
        """#)
        XCTAssertEqual(labs.map(\.limitHeading), ["ULN", "Range"])
    }

    func testLabBandLabels() throws {
        let teenF = try band(#"{"age":"teen","sex":"F","high":22.1,"source":"s"}"#)
        XCTAssertEqual(teenF.ageLabel, "11–18 y")
        XCTAssertEqual(teenF.sexLabel, "F")
        let fine = try band(#"{"age":"0–7 d","high":1,"source":"s"}"#)
        XCTAssertEqual(fine.ageLabel, "0–7 d", "a finer band keeps its own label")
        XCTAssertEqual(fine.sexLabel, "All")
    }

    func testLabBandMatchesOnlyTheSelectedAgeBand() throws {
        let teen = try band(#"{"age":"teen","high":1,"source":"s"}"#)
        XCTAssertTrue(teen.matches(.teen))
        XCTAssertFalse(teen.matches(.child))
        XCTAssertFalse(teen.matches(.neo))
        XCTAssertFalse(teen.matches(nil), "nothing is highlighted before an age is chosen")
        XCTAssertFalse(try band(#"{"age":"0–7 d","high":1,"source":"s"}"#).matches(.neo), "a finer band without within never matches")
    }

    func testFinerBandMatchesItsParentAgeBand() throws {
        let firstWeek = try band(#"{"age":"0–7 d","within":"neo","high":1,"source":"s"}"#)
        XCTAssertEqual(firstWeek.ageBand, .neo)
        XCTAssertEqual(firstWeek.ageLabel, "0–7 d")
        XCTAssertTrue(firstWeek.matches(.neo))
        XCTAssertFalse(firstWeek.matches(.infant))
        XCTAssertFalse(firstWeek.matches(nil))
    }

    func testLabTestNoteIsOptional() throws {
        let labs = try decode([LabTest].self, #"""
        [{"id":"a","name":"A","unit":"U/L","note":"Health-based cut-off.","bands":[{"age":"teen","high":22,"source":"s"}]},
         {"id":"b","name":"B","unit":"U/L","bands":[{"age":"teen","high":22,"source":"s"}]}]
        """#)
        XCTAssertEqual(labs.first?.note, "Health-based cut-off.")
        XCTAssertNil(labs.last?.note)
    }

    func testPlanBlock() throws {
        let plan = try decode([PlanBlock].self, #"""
        [{"block":2,"title":"Neonatal cholestasis: approach","start":"2026-10-12",
          "days":[{"day":1,"topic":"Epidemiology and definitions","cards":["neo_jaundice","chol_0_3m"]}]}]
        """#)
        XCTAssertEqual(plan.first?.id, 2)
        XCTAssertEqual(plan.first?.days.first?.cards, ["neo_jaundice", "chol_0_3m"])
    }

    func testCaseAndSynonyms() throws {
        let cases = try decode([ClinicalCase].self, #"""
        [{"id":"c1","card":"chol_0_3m","stem":"s","question":"q","answer":"a","teaching":"t"}]
        """#)
        XCTAssertEqual(cases.first?.card, "chol_0_3m")
        let synonyms = try decode([String: [String]].self, #"{"biliary atresia":["BA","kasai"]}"#)
        XCTAssertEqual(synonyms["biliary atresia"], ["BA", "kasai"])
    }

    /// The bundled registries load through the app's own loader.
    func testBundledRegistryLoads() {
        let registry = Registry(bundle: Bundle(for: RegistryDecodingTests.self))
        XCTAssertEqual(registry.plan.count, 26)
        // Adolescent ALT limits, AASLD 2025 (> 22 U/L girls, > 26 U/L boys;
        // SAFETY 2010 rounded, as in NASPGHAN 2017).
        let alt = registry.lab("alt")
        XCTAssertEqual(alt?.bands.first { $0.sex == .F }?.high, 22)
        XCTAssertEqual(alt?.bands.first { $0.sex == .M }?.high, 26)
        XCTAssertEqual(alt?.bands.first?.source, "aasld_2025_masld_peds")
    }
}
