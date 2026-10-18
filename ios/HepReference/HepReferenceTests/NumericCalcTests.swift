import XCTest
@testable import HepReference

final class NACCalcTests: XCTestCase {
    func testUncappedWeight() throws {
        let r = try XCTUnwrap(NACCalc.compute(weightKg: 30))
        XCTAssertEqual(r.loadMg, 4500)
        XCTAssertEqual(r.maintMg, 9000)
        XCTAssertEqual(r.rateMgPerHour, 450)
        XCTAssertEqual(r.totalMg, 13500)
        XCTAssertFalse(r.loadCapped)
        XCTAssertFalse(r.maintCapped)
        XCTAssertFalse(r.rateCapped)
        XCTAssertEqual(r.loadML, 22.5, accuracy: 0.01)
        XCTAssertEqual(r.maintML, 45.0, accuracy: 0.01)
    }

    func testWeightAboveBothCaps() throws {
        let r = try XCTUnwrap(NACCalc.compute(weightKg: 150))
        XCTAssertEqual(r.loadMg, 15000)
        XCTAssertEqual(r.maintMg, 15000)
        XCTAssertEqual(r.rateMgPerHour, 750)
        XCTAssertTrue(r.loadCapped)
        XCTAssertTrue(r.maintCapped)
        XCTAssertTrue(r.rateCapped)
    }

    func testInvalidWeightReturnsNil() {
        XCTAssertNil(NACCalc.compute(weightKg: 0))
        XCTAssertNil(NACCalc.compute(weightKg: -5))
    }
}
