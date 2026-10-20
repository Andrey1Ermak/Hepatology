import XCTest
@testable import HepReference

final class CardDecodingTests: XCTestCase {
    private func decodeCard(_ json: String) throws -> Card {
        try JSONDecoder().decode(Card.self, from: Data(json.utf8))
    }

    func testCardWithAllMetadata() throws {
        let card = try decodeCard(#"""
        {"id":"chol_0_3m","title":"Cholestasis 0–3 Months","code":"NASPGHAN/ESPGHAN 2017",
         "cat":"jaundice","acu":"crit","tags":["cholestasis"],
         "ages":["neo","infant"],"entry":"symptom",
         "guidelines":["naspghan_espghan_2017_nc"],
         "plan":[{"block":2,"days":[1,3]},{"block":3,"days":[3,4]}],
         "related":["chol_3_12m","chol_low_ggt"],"status":"reviewed","blocks":[]}
        """#)
        XCTAssertEqual(card.ages, [.neo, .infant])
        XCTAssertEqual(card.entry, .symptom)
        XCTAssertEqual(card.guidelines, ["naspghan_espghan_2017_nc"])
        XCTAssertEqual(card.plan, [PlanRef(block: 2, days: [1, 3]), PlanRef(block: 3, days: [3, 4])])
        XCTAssertEqual(card.related, ["chol_3_12m", "chol_low_ggt"])
        XCTAssertEqual(card.status, .reviewed)
    }

    /// Cards written before the metadata existed still decode.
    func testCardWithoutMetadata() throws {
        let card = try decodeCard(#"""
        {"id":"about","title":"About","code":"v0.1","cat":"ref","acu":"ref","tags":[],"blocks":[]}
        """#)
        XCTAssertNil(card.ages)
        XCTAssertNil(card.entry)
        XCTAssertNil(card.guidelines)
        XCTAssertNil(card.plan)
        XCTAssertNil(card.related)
        XCTAssertNil(card.status)
    }

    func testEveryStatusDecodes() throws {
        for raw in ["draft", "reviewed", "approved"] {
            let card = try decodeCard(#"{"id":"x","title":"x","code":"x","cat":"ref","acu":"ref","tags":[],"blocks":[],"status":"\#(raw)"}"#)
            XCTAssertEqual(card.status?.rawValue, raw)
        }
    }

    /// A typo in an enum field fails loudly instead of dropping the value.
    func testUnknownStatusOrAgeFails() {
        XCTAssertThrowsError(try decodeCard(#"{"id":"x","title":"x","code":"x","cat":"ref","acu":"ref","tags":[],"blocks":[],"status":"done"}"#))
        XCTAssertThrowsError(try decodeCard(#"{"id":"x","title":"x","code":"x","cat":"ref","acu":"ref","tags":[],"blocks":[],"ages":["adult"]}"#))
    }
}
