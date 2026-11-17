import XCTest
@testable import HepReference

final class StudyPlanTests: XCTestCase {
    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "America/New_York")!
        return c
    }

    private func at(_ text: String, hour: Int = 12) -> Date {
        let day = StudyPlan.date(text, calendar: calendar)!
        return calendar.date(byAdding: .hour, value: hour, to: day)!
    }

    private func block(_ n: Int, start: String) -> PlanBlock {
        let days = (1...14).map { #"{"day":\#($0),"topic":"t\#($0)","cards":[]}"# }.joined(separator: ",")
        let json = #"{"block":\#(n),"title":"B\#(n)","start":"\#(start)","days":[\#(days)]}"#
        return try! JSONDecoder().decode(PlanBlock.self, from: Data(json.utf8))
    }

    private var plan: [PlanBlock] {
        [block(1, start: "2026-09-28"), block(2, start: "2026-10-12")]
    }

    func testFirstAndLastDayOfBlock() {
        XCTAssertEqual(StudyPlan.position(on: at("2026-09-28"), in: plan, calendar: calendar), PlanPosition(block: 1, day: 1))
        XCTAssertEqual(StudyPlan.position(on: at("2026-10-11"), in: plan, calendar: calendar), PlanPosition(block: 1, day: 14))
        XCTAssertEqual(StudyPlan.position(on: at("2026-10-12"), in: plan, calendar: calendar), PlanPosition(block: 2, day: 1))
    }

    func testDayChangesAtLocalMidnight() {
        XCTAssertEqual(StudyPlan.position(on: at("2026-10-12", hour: 0), in: plan, calendar: calendar)?.day, 1)
        XCTAssertEqual(StudyPlan.position(on: at("2026-10-12", hour: 23), in: plan, calendar: calendar)?.day, 1)
    }

    /// Daylight-saving change (Nov 1, 2026 in New York) must not shift the day.
    func testAcrossDaylightSavingChange() {
        XCTAssertEqual(StudyPlan.position(on: at("2026-11-02", hour: 0), in: [block(4, start: "2026-10-26")], calendar: calendar),
                       PlanPosition(block: 4, day: 8))
    }

    func testOutsideThePlan() {
        XCTAssertNil(StudyPlan.position(on: at("2026-09-27"), in: plan, calendar: calendar))
        XCTAssertNil(StudyPlan.position(on: at("2026-10-26"), in: plan, calendar: calendar))
        XCTAssertEqual(StudyPlan.initialBlock(on: at("2026-09-01"), in: plan, calendar: calendar), 1)
        XCTAssertEqual(StudyPlan.initialBlock(on: at("2027-01-01"), in: plan, calendar: calendar), 2)
        XCTAssertEqual(StudyPlan.initialBlock(on: at("2026-10-20"), in: plan, calendar: calendar), 2)
        XCTAssertNil(StudyPlan.initialBlock(on: at("2026-10-20"), in: [], calendar: calendar))
    }

    func testScrollTarget() {
        XCTAssertEqual(StudyPlan.scrollTarget(in: plan[1], today: PlanPosition(block: 2, day: 9)), 9)
        XCTAssertEqual(StudyPlan.scrollTarget(in: plan[0], today: PlanPosition(block: 2, day: 9)), 1)
        XCTAssertEqual(StudyPlan.scrollTarget(in: plan[0], today: nil), 1)
    }

    /// A date between two non-adjacent blocks belongs to neither.
    func testGapBetweenBlocks() {
        let gapped = [block(1, start: "2026-09-28"), block(2, start: "2026-10-19")]
        XCTAssertNil(StudyPlan.position(on: at("2026-10-14"), in: gapped, calendar: calendar))
        XCTAssertEqual(StudyPlan.position(on: at("2026-10-19"), in: gapped, calendar: calendar), PlanPosition(block: 2, day: 1))
    }

    func testDateOfDay() {
        let date = StudyPlan.date(of: 14, in: plan[1], calendar: calendar)
        XCTAssertEqual(date, StudyPlan.date("2026-10-25", calendar: calendar))
    }

    func testBadDateText() {
        XCTAssertNil(StudyPlan.date("2026-10", calendar: calendar))
        XCTAssertNil(StudyPlan.date("soon", calendar: calendar))
    }

    func testLessonStampDecodes() throws {
        let day = try JSONDecoder().decode(PlanDay.self, from: Data(#"{"day":1,"topic":"t","cards":[],"lesson":"2026-11-17"}"#.utf8))
        XCTAssertEqual(day.lesson, "2026-11-17")
        let none = try JSONDecoder().decode(PlanDay.self, from: Data(#"{"day":1,"topic":"t","cards":[]}"#.utf8))
        XCTAssertNil(none.lesson)
    }

    /// The bundled plan resolves a date inside the year to its block and day.
    func testBundledPlan() {
        let registry = Registry(bundle: Bundle(for: StudyPlanTests.self))
        XCTAssertEqual(StudyPlan.position(on: at("2026-11-17"), in: registry.plan, calendar: calendar), PlanPosition(block: 4, day: 9))
    }
}
