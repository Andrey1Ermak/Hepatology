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

final class ULNCalcTests: XCTestCase {
    private let labs = Registry(bundle: Bundle(for: ULNCalcTests.self)).labs

    /// Lesson 01-01: ALT 90 U/L against a ULN of 35 is 2.57 × ULN — mild.
    func testLessonExample() throws {
        let m = try XCTUnwrap(ULNCalc.multiple(value: 90, uln: 35))
        XCTAssertEqual(m, 2.571, accuracy: 0.001)
        XCTAssertEqual(ULNCalc.format(m), "2.57")
        XCTAssertEqual(ULNCalc.grade(enzyme: .alt, value: 90, multiple: m), .mild)
    }

    func testInvalidInputReturnsNil() {
        XCTAssertNil(ULNCalc.multiple(value: 90, uln: 0))
        XCTAssertNil(ULNCalc.multiple(value: -1, uln: 35))
    }

    /// AASLD 2025 health-based ALT ULN: 22 U/L girls, 26 U/L boys, 11–18 y.
    func testReferenceFromLabsJSON() throws {
        let girl = try XCTUnwrap(ULNCalc.reference(in: labs, enzyme: .alt, age: .teen, sex: .F))
        XCTAssertEqual(girl.high, 22)
        XCTAssertEqual(girl.source, "aasld_2025_masld_peds")
        XCTAssertEqual(ULNCalc.reference(in: labs, enzyme: .alt, age: .teen, sex: .M)?.high, 26)
    }

    /// No band, no reference: the fellow must use the laboratory's ULN.
    func testNoReferenceWithoutValidatedBand() {
        XCTAssertNil(ULNCalc.reference(in: labs, enzyme: .alt, age: .child, sex: .F))
        XCTAssertNil(ULNCalc.reference(in: labs, enzyme: .alt, age: .teen, sex: nil))
        XCTAssertNil(ULNCalc.reference(in: labs, enzyme: .alt, age: nil, sex: .M))
        XCTAssertNil(ULNCalc.reference(in: labs, enzyme: .ggt, age: .teen, sex: .M))
        XCTAssertNil(ULNCalc.reference(in: labs, enzyme: .alp, age: .infant, sex: .F))
    }

    /// ACG 2017 bands: < 2 borderline, 2–5 mild, 5–15 moderate, > 15
    /// severe, > 10,000 U/L massive; edges per D-2026-10-30-2.
    func testACGGradeBoundaries() {
        let cases: [(Double, AminotransferaseGrade)] = [
            (1.0, .withinULN), (1.5, .borderline), (1.99, .borderline), (2.0, .mild),
            (5.0, .mild), (5.01, .moderate), (15.0, .moderate), (15.01, .severe),
        ]
        for (multiple, grade) in cases {
            XCTAssertEqual(ULNCalc.grade(enzyme: .ast, value: 100, multiple: multiple), grade, "\(multiple) × ULN")
        }
        XCTAssertEqual(ULNCalc.grade(enzyme: .alt, value: 10_001, multiple: 400), .massive)
        XCTAssertEqual(ULNCalc.grade(enzyme: .alt, value: 10_000, multiple: 400), .severe)
        // An absolute value over 10,000 is massive whatever the lab ULN.
        XCTAssertEqual(ULNCalc.grade(enzyme: .ast, value: 12_000, multiple: 1), .massive)
        // Shown values are truncated, never rounded up onto a band edge.
        XCTAssertEqual(ULNCalc.format(1.996), "1.99")
    }

    func testNoGradeForGGTOrALP() {
        XCTAssertNil(ULNCalc.grade(enzyme: .ggt, value: 300, multiple: 6))
        XCTAssertNil(ULNCalc.grade(enzyme: .alp, value: 900, multiple: 3))
    }
}

final class RRatioCalcTests: XCTestCase {
    /// Lesson 01-01 worked example: a 14-year-old boy, ALT 90 (ULN 35),
    /// ALP 400. Against his own ALP ULN of 525, R ≈ 3.4 (mixed); against the
    /// adult ULN of 126, R falls below 1 and looks cholestatic.
    func testLessonExampleChildVersusAdultULN() throws {
        let child = try XCTUnwrap(RRatioCalc.compute(alt: 90, altULN: 35, alp: 400, alpULN: 525))
        XCTAssertEqual(child.r, 3.375, accuracy: 0.001)
        XCTAssertEqual(child.pattern, .mixed)
        let adult = try XCTUnwrap(RRatioCalc.compute(alt: 90, altULN: 35, alp: 400, alpULN: 126))
        XCTAssertEqual(adult.r, 0.81, accuracy: 0.001)
        XCTAssertEqual(adult.pattern, .cholestatic)
    }

    /// R ≥ 5 hepatocellular, R ≤ 2 cholestatic (ACG 2021, AASLD 2023, EASL 2019).
    func testPatternBoundaries() throws {
        XCTAssertEqual(try XCTUnwrap(RRatioCalc.compute(alt: 250, altULN: 50, alp: 100, alpULN: 100)).pattern, .hepatocellular)
        XCTAssertEqual(try XCTUnwrap(RRatioCalc.compute(alt: 100, altULN: 50, alp: 100, alpULN: 100)).pattern, .cholestatic)
        XCTAssertEqual(try XCTUnwrap(RRatioCalc.compute(alt: 249, altULN: 50, alp: 100, alpULN: 100)).pattern, .mixed)
        XCTAssertEqual(try XCTUnwrap(RRatioCalc.compute(alt: 101, altULN: 50, alp: 100, alpULN: 100)).pattern, .mixed)
        XCTAssertEqual(RRatioCalc.format(4.996), "4.99")
        // Exact edges with values that chained divisions would round wrongly.
        let five = try XCTUnwrap(RRatioCalc.compute(alt: 374, altULN: 40, alp: 561, alpULN: 300))
        XCTAssertEqual(five.r, 5)
        XCTAssertEqual(five.pattern, .hepatocellular)
        let two = try XCTUnwrap(RRatioCalc.compute(alt: 120, altULN: 40, alp: 450, alpULN: 300))
        XCTAssertEqual(two.r, 2)
        XCTAssertEqual(two.pattern, .cholestatic)
    }

    /// nR uses the higher of ALT and AST multiples; it needs both AST and its ULN.
    func testNewR() throws {
        let higherAST = try XCTUnwrap(RRatioCalc.compute(alt: 100, altULN: 50, alp: 200, alpULN: 100, ast: 600, astULN: 40))
        XCTAssertEqual(higherAST.r, 1, accuracy: 0.001)
        XCTAssertEqual(higherAST.pattern, .cholestatic)
        XCTAssertEqual(try XCTUnwrap(higherAST.nR), 7.5, accuracy: 0.001)
        XCTAssertEqual(higherAST.nRPattern, .hepatocellular)
        let higherALT = try XCTUnwrap(RRatioCalc.compute(alt: 300, altULN: 50, alp: 100, alpULN: 100, ast: 40, astULN: 40))
        XCTAssertEqual(try XCTUnwrap(higherALT.nR), higherALT.r, accuracy: 0.001)
        XCTAssertNil(try XCTUnwrap(RRatioCalc.compute(alt: 100, altULN: 50, alp: 100, alpULN: 100, ast: 600)).nR)
    }

    /// R only means something once a test is abnormal.
    func testAllWithinULN() throws {
        XCTAssertTrue(try XCTUnwrap(RRatioCalc.compute(alt: 30, altULN: 30, alp: 100, alpULN: 400)).allWithinULN)
        XCTAssertFalse(try XCTUnwrap(RRatioCalc.compute(alt: 31, altULN: 30, alp: 100, alpULN: 400)).allWithinULN)
        XCTAssertFalse(try XCTUnwrap(RRatioCalc.compute(alt: 30, altULN: 30, alp: 100, alpULN: 400, ast: 90, astULN: 40)).allWithinULN)
    }

    func testInvalidInputReturnsNil() {
        XCTAssertNil(RRatioCalc.compute(alt: 100, altULN: 50, alp: 0, alpULN: 100))
        XCTAssertNil(RRatioCalc.compute(alt: 100, altULN: 0, alp: 100, alpULN: 100))
        XCTAssertNil(RRatioCalc.compute(alt: 0, altULN: 50, alp: 100, alpULN: 100))
    }
}

final class NumericCalcSourceTests: XCTestCase {
    /// Every source a numeric calculator cites resolves in guidelines.json,
    /// and every registered calculator has a real title.
    func testCalculatorSourcesExist() {
        let registry = Registry(bundle: Bundle(for: NumericCalcSourceTests.self))
        for id in ULNCalc.sourceIds + RRatioCalc.sourceIds + APRIGPRCalc.sourceIds {
            XCTAssertNotNil(registry.guideline(id), "calculator source '\(id)' missing from guidelines.json")
        }
        for id in NumericCalcRegistry.ids {
            XCTAssertNotEqual(NumericCalcRegistry.title(for: id), id, "\(id): no title")
            XCTAssertNotNil(NumericCalcRegistry.view(for: id), "\(id): no view")
        }
    }
}

final class APRIGPRCalcTests: XCTestCase {
    /// Wai 2003 formula: AST twice the ULN with platelets 200 gives APRI 1.0.
    func testAPRIFormula() throws {
        XCTAssertEqual(try XCTUnwrap(APRIGPRCalc.index(value: 80, uln: 40, platelets: 200)), 1.0)
        XCTAssertEqual(try XCTUnwrap(APRIGPRCalc.index(value: 45, uln: 40, platelets: 250)), 0.45, accuracy: 0.0001)
    }

    /// Lemoine 2016 formula: GGT twice the ULN with platelets 100 gives GPR 2.0.
    func testGPRFormula() throws {
        XCTAssertEqual(try XCTUnwrap(APRIGPRCalc.index(value: 60, uln: 30, platelets: 100)), 2.0)
    }

    /// The same AST reads one-third higher against ULN 30 than ULN 40.
    func testAPRIDependsOnTheLabULN() throws {
        let uln40 = try XCTUnwrap(APRIGPRCalc.index(value: 60, uln: 40, platelets: 150))
        let uln30 = try XCTUnwrap(APRIGPRCalc.index(value: 60, uln: 30, platelets: 150))
        XCTAssertEqual(uln30 / uln40, 4.0 / 3.0, accuracy: 0.0001)
    }

    /// Reference points are "> cut-off": a value exactly on a threshold is not above it.
    func testThresholdsAreStrict() throws {
        let half = try XCTUnwrap(APRIGPRCalc.index(value: 50, uln: 40, platelets: 250))
        XCTAssertEqual(half, 0.5)
        let who = APRIGPRCalc.apriReferences.map { APRIGPRCalc.isAbove(half, $0) }
        XCTAssertEqual(who, [true, false, false])
        let one = try XCTUnwrap(APRIGPRCalc.index(value: 100, uln: 40, platelets: 250))
        XCTAssertEqual(APRIGPRCalc.apriReferences.map { APRIGPRCalc.isAbove(one, $0) }, [true, true, false])
        let gprEdge = try XCTUnwrap(APRIGPRCalc.index(value: 30, uln: 50, platelets: 300))
        XCTAssertEqual(gprEdge, 0.2)
        XCTAssertFalse(APRIGPRCalc.isAbove(gprEdge, APRIGPRCalc.gprReferences[0]))
    }

    /// Published cut-offs, in ascending order: Leung 2015, WHO 2024, Calvopina 2022.
    func testReferencePoints() {
        XCTAssertEqual(APRIGPRCalc.apriReferences.map(\.threshold), [0.264, 0.5, 1.0])
        XCTAssertEqual(APRIGPRCalc.gprReferences.map(\.threshold), [0.20])
        for ref in APRIGPRCalc.apriReferences + APRIGPRCalc.gprReferences {
            XCTAssertEqual(Double(ref.thresholdText), ref.threshold)
        }
    }

    func testInvalidInputReturnsNil() {
        XCTAssertNil(APRIGPRCalc.index(value: 80, uln: 40, platelets: 0))
        XCTAssertNil(APRIGPRCalc.index(value: 80, uln: 0, platelets: 200))
        XCTAssertNil(APRIGPRCalc.index(value: 0, uln: 40, platelets: 200))
        XCTAssertNil(APRIGPRCalc.index(value: -5, uln: 40, platelets: 200))
    }

    func testFormat() {
        XCTAssertEqual(APRIGPRCalc.format(0.264), "0.26")
        XCTAssertEqual(APRIGPRCalc.format(1.236), "1.24")
        XCTAssertEqual(APRIGPRCalc.format(2), "2.00")
        // Near a reference point, a third decimal keeps number and label consistent.
        XCTAssertEqual(APRIGPRCalc.format(0.5004, near: APRIGPRCalc.apriReferences), "0.5004")
        XCTAssertEqual(APRIGPRCalc.format(0.4996, near: APRIGPRCalc.apriReferences), "0.4996")
        XCTAssertEqual(APRIGPRCalc.format(0.2641, near: APRIGPRCalc.apriReferences), "0.2641")
        XCTAssertEqual(APRIGPRCalc.format(0.5, near: APRIGPRCalc.apriReferences), "0.50")
        XCTAssertEqual(APRIGPRCalc.format(0.75, near: APRIGPRCalc.apriReferences), "0.75")
    }

    func testReferenceIdsAreUnique() {
        let ids = (APRIGPRCalc.apriReferences + APRIGPRCalc.gprReferences).map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }
}
