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
        for id in ULNCalc.sourceIds + RRatioCalc.sourceIds + APRIGPRCalc.sourceIds + VitaminsCalc.sourceIds
                + ConjBiliCalc.sourceIds + KasaiClockCalc.sourceIds {
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

final class VitaminsCalcTests: XCTestCase {
    /// Mouzaki 2019 Table 3: vitamin A 5,000 IU/day under 10 kg, 10,000 above;
    /// exactly 10 kg takes the lower dose (D-2026-11-10-2).
    func testVitaminAStepsAtTenKilograms() throws {
        XCTAssertEqual(try XCTUnwrap(VitaminsCalc.compute(weightKg: 4)).vitaminAIU, 5_000)
        XCTAssertEqual(try XCTUnwrap(VitaminsCalc.compute(weightKg: 10)).vitaminAIU, 5_000)
        XCTAssertEqual(try XCTUnwrap(VitaminsCalc.compute(weightKg: 10.1)).vitaminAIU, 10_000)
        XCTAssertEqual(try XCTUnwrap(VitaminsCalc.compute(weightKg: 30)).vitaminAIU, 10_000)
    }

    /// TPGS 15–25 IU/kg/day: a 4 kg infant gets 60–100 IU/day; 6.3 kg rounds
    /// to whole IU (94.5 → 95, 157.5 → 158).
    func testTPGSRangeIsPerKilogram() throws {
        let infant = try XCTUnwrap(VitaminsCalc.compute(weightKg: 4))
        XCTAssertEqual(infant.tpgsLowIU, 60)
        XCTAssertEqual(infant.tpgsHighIU, 100)
        let odd = try XCTUnwrap(VitaminsCalc.compute(weightKg: 6.3))
        XCTAssertEqual(odd.tpgsLowIU, 95)
        XCTAssertEqual(odd.tpgsHighIU, 158)
    }

    /// Shneider 2012: separate dosing at total bilirubin ≥ 2 mg/dL; no flag
    /// when bilirubin is not entered.
    func testBilirubinTriggerIsInclusiveAtTwo() throws {
        XCTAssertNil(try XCTUnwrap(VitaminsCalc.compute(weightKg: 5)).separateDosing)
        XCTAssertEqual(try XCTUnwrap(VitaminsCalc.compute(weightKg: 5, totalBilirubin: 1.9)).separateDosing, false)
        XCTAssertEqual(try XCTUnwrap(VitaminsCalc.compute(weightKg: 5, totalBilirubin: 2.0)).separateDosing, true)
        XCTAssertEqual(try XCTUnwrap(VitaminsCalc.compute(weightKg: 5, totalBilirubin: 9.8)).separateDosing, true)
    }

    func testRejectsImplausibleInputs() {
        XCTAssertNil(VitaminsCalc.compute(weightKg: 0))
        XCTAssertNil(VitaminsCalc.compute(weightKg: 0.4))
        XCTAssertNil(VitaminsCalc.compute(weightKg: 151))
        XCTAssertNil(VitaminsCalc.compute(weightKg: 5, totalBilirubin: -1))
        XCTAssertNil(VitaminsCalc.compute(weightKg: 5, totalBilirubin: .nan))
        XCTAssertNil(VitaminsCalc.compute(weightKg: 5, totalBilirubin: .infinity))
        XCTAssertNil(VitaminsCalc.compute(weightKg: 5, totalBilirubin: 51))
        XCTAssertNil(VitaminsCalc.compute(weightKg: .nan))
        XCTAssertNotNil(VitaminsCalc.compute(weightKg: 0.5))
        XCTAssertNotNil(VitaminsCalc.compute(weightKg: 150))
    }

    /// Mouzaki 2019 Table 3 fixed ranges: cholecalciferol 2,000–5,000 IU/day,
    /// vitamin K 2–5 mg/day.
    func testFixedRangesMatchTableThree() {
        XCTAssertEqual(VitaminsCalc.vitaminDRangeIU, 2_000...5_000)
        XCTAssertEqual(VitaminsCalc.vitaminKRangeMg, 2...5)
        XCTAssertEqual(VitaminsCalc.formatRange(VitaminsCalc.vitaminDRangeIU), "2,000–5,000")
        XCTAssertEqual(VitaminsCalc.formatRange(VitaminsCalc.vitaminKRangeMg), "2–5")
    }

    /// Under 2.5 kg the calculator flags that no preterm dose is published.
    func testFlagsLowBirthWeight() throws {
        XCTAssertTrue(try XCTUnwrap(VitaminsCalc.compute(weightKg: 1.8)).belowTermWeight)
        XCTAssertFalse(try XCTUnwrap(VitaminsCalc.compute(weightKg: 2.5)).belowTermWeight)
    }

    func testFormatsThousands() {
        XCTAssertEqual(VitaminsCalc.formatIU(5_000), "5,000")
        XCTAssertEqual(VitaminsCalc.formatIU(10_000), "10,000")
        XCTAssertEqual(VitaminsCalc.formatIU(95), "95")
    }
}

final class ConjBiliCalcTests: XCTestCase {
    /// NASPGHAN/ESPGHAN 2017: direct > 1.0 mg/dL (17 µmol/L) abnormal at any
    /// total; AAP 2025: 1 mg/dL or more — the boundary itself is cholestasis.
    func testThresholdInclusiveInBothUnits() throws {
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: 1.0, unit: .mgdl)).verdict, .cholestasis)
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: 0.99, unit: .mgdl)).verdict, .belowThresholdNoULN)
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: 17, unit: .umol)).verdict, .cholestasis)
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: 16.9, unit: .umol)).verdict, .belowThresholdNoULN)
    }

    /// Lesson 02-03: direct 1.2 with total 12 is cholestasis, not breast-milk
    /// jaundice — the 10% fraction changes nothing.
    func testLessonExampleIgnoresFraction() throws {
        let r = try XCTUnwrap(ConjBiliCalc.compute(direct: 1.2, unit: .mgdl, total: 12))
        XCTAssertEqual(r.verdict, .cholestasis)
        XCTAssertEqual(try XCTUnwrap(r.fraction), 0.1, accuracy: 1e-9)
        XCTAssertEqual(ConjBiliCalc.formatPercent(0.1), "10%")
        XCTAssertFalse(r.directExceedsTotal)
    }

    /// Lesson 02-02 case: day 2, conjugated 0.4 mg/dL, lab limit 0.3 → above
    /// the range (AAP 2025: abnormal even by 0.1); at the limit → within.
    func testLabUpperLimit() throws {
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: 0.4, unit: .mgdl, labULN: 0.3, age: .under2Weeks)).verdict, .aboveLabRangeNewborn)
        // 2 weeks or older, or age not given: hepatology today (as card 6).
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: 0.5, unit: .mgdl, labULN: 0.3, age: .twoWeeksOrOlder)).verdict, .aboveLabRangeOlder)
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: 0.5, unit: .mgdl, labULN: 0.3)).verdict, .aboveLabRangeOlder)
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: 0.3, unit: .mgdl, labULN: 0.3)).verdict, .withinLabRange)
        // The absolute threshold wins over a generous lab range.
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: 1.1, unit: .mgdl, labULN: 1.5)).verdict, .cholestasis)
    }

    func testPaleStoolOverridesNumber() throws {
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: 0.2, unit: .mgdl, labULN: 0.3, paleStool: true)).verdict, .paleStool)
        // No number yet, or an entry error: the override still shows.
        XCTAssertEqual(try XCTUnwrap(ConjBiliCalc.compute(direct: nil, unit: .mgdl, paleStool: true)).verdict, .paleStool)
        let r = try XCTUnwrap(ConjBiliCalc.compute(direct: 3, unit: .mgdl, total: 2, paleStool: true))
        XCTAssertEqual(r.verdict, .paleStool)
        XCTAssertTrue(r.directExceedsTotal)
    }

    /// A lab limit at or above the threshold was probably typed in the other unit.
    func testSuspectLabULN() throws {
        let suspect = try XCTUnwrap(ConjBiliCalc.compute(direct: 0.8, unit: .mgdl, labULN: 5))
        XCTAssertTrue(suspect.labULNSuspect)
        XCTAssertEqual(suspect.verdict, .belowThresholdNoULN, "no green verdict on a suspect limit")
        XCTAssertFalse(try XCTUnwrap(ConjBiliCalc.compute(direct: 0.8, unit: .mgdl, labULN: 0.3)).labULNSuspect)
        XCTAssertFalse(try XCTUnwrap(ConjBiliCalc.compute(direct: 10, unit: .umol, labULN: 5)).labULNSuspect)
    }

    func testEntryErrorsAndInvalidInput() throws {
        XCTAssertTrue(try XCTUnwrap(ConjBiliCalc.compute(direct: 3, unit: .mgdl, total: 2)).directExceedsTotal)
        XCTAssertNil(ConjBiliCalc.compute(direct: 0, unit: .mgdl))
        XCTAssertNil(ConjBiliCalc.compute(direct: -1, unit: .mgdl))
        XCTAssertNil(ConjBiliCalc.compute(direct: .nan, unit: .mgdl))
        XCTAssertNil(ConjBiliCalc.compute(direct: .infinity, unit: .mgdl))
        XCTAssertNil(ConjBiliCalc.compute(direct: nil, unit: .mgdl))
        // Zero optional inputs count as absent.
        let r = try XCTUnwrap(ConjBiliCalc.compute(direct: 0.5, unit: .mgdl, total: 0, labULN: 0))
        XCTAssertNil(r.fraction)
        XCTAssertEqual(r.verdict, .belowThresholdNoULN)
    }
}

final class KasaiClockCalcTests: XCTestCase {
    private var utc: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }

    private func date(_ y: Int, _ m: Int, _ d: Int, hour: Int = 12, in cal: Calendar) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d, hour: hour))!
    }

    /// Born 1 Oct, seen 5 Nov → 35 days: 31–45 band, day 30 passed 5 days ago,
    /// day 45 in 10 days, day 60 in 25 days.
    func testAgeAndMilestones() throws {
        let r = try XCTUnwrap(KasaiClockCalc.compute(birth: date(2026, 10, 1, in: utc), today: date(2026, 11, 5, in: utc), calendar: utc))
        XCTAssertEqual(r.ageDays, 35)
        XCTAssertEqual(r.band, .d31to45)
        XCTAssertEqual(r.milestones.map(\.daysLeft), [-5, 10, 25])
        XCTAssertEqual(KasaiClockCalc.formatMilestone(r.milestones[0]), "5 days past")
        XCTAssertEqual(KasaiClockCalc.formatMilestone(.init(day: 30, daysLeft: -1)), "1 day past")
        XCTAssertEqual(KasaiClockCalc.formatWeeks(59), "8 wk 3 d")
        XCTAssertEqual(KasaiClockCalc.formatMilestone(r.milestones[1]), "in 10 days")
        XCTAssertEqual(KasaiClockCalc.formatWeeks(35), "5 wk 0 d")
    }

    /// Calendar days, not 24-hour blocks: born late evening, seen next
    /// morning is day 1; a daylight-saving change does not lose a day.
    func testCalendarDaysAcrossDST() throws {
        XCTAssertEqual(KasaiClockCalc.ageDays(birth: date(2026, 3, 1, hour: 23, in: utc), today: date(2026, 3, 2, hour: 1, in: utc), calendar: utc), 1)
        var ny = Calendar(identifier: .gregorian)
        ny.timeZone = TimeZone(identifier: "America/New_York")!
        // US DST starts 8 March 2026.
        XCTAssertEqual(KasaiClockCalc.ageDays(birth: date(2026, 3, 1, hour: 0, in: ny), today: date(2026, 3, 31, hour: 0, in: ny), calendar: ny), 30)
    }

    /// Serinet 2009 bands: ≤ 30, 31–45, 46–60; then 61–90 and > 90 (Schreiber 2007).
    func testBandBoundaries() {
        XCTAssertEqual(KasaiClockCalc.Band(ageDays: 0), .upTo30)
        XCTAssertEqual(KasaiClockCalc.Band(ageDays: 30), .upTo30)
        XCTAssertEqual(KasaiClockCalc.Band(ageDays: 31), .d31to45)
        XCTAssertEqual(KasaiClockCalc.Band(ageDays: 45), .d31to45)
        XCTAssertEqual(KasaiClockCalc.Band(ageDays: 46), .d46to60)
        XCTAssertEqual(KasaiClockCalc.Band(ageDays: 60), .d46to60)
        XCTAssertEqual(KasaiClockCalc.Band(ageDays: 61), .d61to90)
        XCTAssertEqual(KasaiClockCalc.Band(ageDays: 90), .d61to90)
        XCTAssertEqual(KasaiClockCalc.Band(ageDays: 91), .over90)
        XCTAssertFalse(KasaiClockCalc.Band(ageDays: 60).isLate)
        XCTAssertTrue(KasaiClockCalc.Band(ageDays: 61).isLate)
    }

    func testMilestoneOnTheDayAndFutureBirth() throws {
        let r = try XCTUnwrap(KasaiClockCalc.compute(ageDays: 45))
        XCTAssertEqual(KasaiClockCalc.formatMilestone(r.milestones[1]), "today")
        XCTAssertNil(KasaiClockCalc.compute(birth: date(2026, 11, 6, in: utc), today: date(2026, 11, 5, in: utc), calendar: utc))
        XCTAssertNil(KasaiClockCalc.compute(ageDays: -1))
    }
}
