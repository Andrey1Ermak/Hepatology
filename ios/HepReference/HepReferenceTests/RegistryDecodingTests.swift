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
    }
}
