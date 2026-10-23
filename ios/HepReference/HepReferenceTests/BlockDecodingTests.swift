import XCTest
@testable import HepReference

final class BlockDecodingTests: XCTestCase {
    private func decodeBlock(_ json: String) throws -> Block {
        try JSONDecoder().decode(Block.self, from: Data(json.utf8))
    }

    func testNote() throws {
        guard case .note(let block) = try decodeBlock(#"{"t":"note","k":"crit","text":"**give** hydrocortisone first"}"#) else {
            return XCTFail("expected note")
        }
        XCTAssertEqual(block.k, .crit)
        XCTAssertEqual(block.text, "**give** hydrocortisone first")
    }

    func testListWithPlainAndTitledItems() throws {
        let json = #"""
        {"h":"Minor consent by service","t":"list","items":[
          "Plain bullet item.",
          {"t":"Contraception","sub":["Confidential care.","Separate consent for procedures."]}
        ]}
        """#
        guard case .list(let block) = try decodeBlock(json) else {
            return XCTFail("expected list")
        }
        XCTAssertEqual(block.items.count, 2)
        guard case .plain(let plain) = block.items[0] else {
            return XCTFail("expected plain item")
        }
        XCTAssertEqual(plain, "Plain bullet item.")
        guard case .titled(let title, let sub) = block.items[1] else {
            return XCTFail("expected titled item")
        }
        XCTAssertEqual(title, "Contraception")
        XCTAssertEqual(sub, ["Confidential care.", "Separate consent for procedures."])
    }

    func testDose() throws {
        let json = #"""
        {"t":"dose","items":[
          {"d":"D10W","x":["5 mL/kg IV/IO"],"n":"= 0.5 g/kg"}
        ]}
        """#
        guard case .dose(let block) = try decodeBlock(json) else {
            return XCTFail("expected dose")
        }
        XCTAssertEqual(block.items[0].d, "D10W")
        XCTAssertEqual(block.items[0].x, ["5 mL/kg IV/IO"])
        XCTAssertEqual(block.items[0].n, "= 0.5 g/kg")
    }

    func testBranch() throws {
        let json = #"""
        {"h":"Management by hemoglobin","t":"branch","opts":[
          {"if":"Hgb >6 g/dL","then":"Discharge home."}
        ]}
        """#
        guard case .branch(let block) = try decodeBlock(json) else {
            return XCTFail("expected branch")
        }
        XCTAssertEqual(block.opts[0].if, "Hgb >6 g/dL")
        XCTAssertEqual(block.opts[0].then, "Discharge home.")
    }

    func testKV() throws {
        let json = #"{"t":"kv","rows":[["Trauma","[m]864-9439[/m]"]]}"#
        guard case .kv(let block) = try decodeBlock(json) else {
            return XCTFail("expected kv")
        }
        XCTAssertEqual(block.rows[0].key, "Trauma")
        XCTAssertEqual(block.rows[0].value, "[m]864-9439[/m]")
    }

    func testTable() throws {
        let json = #"""
        {"h":"Recognize the toxidrome","t":"table","head":["Pattern","Clues"],"rows":[
          ["Opioid","miosis -> naloxone"]
        ]}
        """#
        guard case .table(let block) = try decodeBlock(json) else {
            return XCTFail("expected table")
        }
        XCTAssertEqual(block.head, ["Pattern", "Clues"])
        XCTAssertEqual(block.rows[0], ["Opioid", "miosis -> naloxone"])
    }

    func testText() throws {
        let json = #"{"t":"text","text":"Free paragraph content."}"#
        guard case .text(let block) = try decodeBlock(json) else {
            return XCTFail("expected text")
        }
        XCTAssertEqual(block.text, "Free paragraph content.")
    }

    func testChipScreen() throws {
        let json = #"{"t":"chip_screen","calc_id":"c_palf","label":"PALF screen"}"#
        guard case .chipScreen(let block) = try decodeBlock(json) else {
            return XCTFail("expected chip_screen")
        }
        XCTAssertEqual(block.calcId, "c_palf")
        XCTAssertEqual(block.label, "PALF screen")
    }

    func testPathway() throws {
        let json = #"{"t":"pathway","path_id":"dkapath"}"#
        guard case .pathway(let block) = try decodeBlock(json) else {
            return XCTFail("expected pathway")
        }
        XCTAssertEqual(block.pathId, "dkapath")
    }

    func testScoreCalc() throws {
        let json = #"{"t":"score_calc","calc_id":"ads","label":"Asthma Distress Score"}"#
        guard case .scoreCalc(let block) = try decodeBlock(json) else {
            return XCTFail("expected score_calc")
        }
        XCTAssertEqual(block.calcId, "ads")
    }

    func testNumericCalc() throws {
        let json = #"{"t":"numeric_calc","calc_id":"nac","label":"NAC dosing"}"#
        guard case .numericCalc(let block) = try decodeBlock(json) else {
            return XCTFail("expected numeric_calc")
        }
        XCTAssertEqual(block.calcId, "nac")
    }

    func testAgeSwitch() throws {
        let json = #"""
        {"t":"age_switch","h":"Age","options":[
          {"age":"neo","label":"0–28 d","path_id":"chol_0_3m_neo"},
          {"age":"infant","label":"1–3 mo","path_id":"chol_0_3m_infant"}]}
        """#
        guard case .ageSwitch(let block) = try decodeBlock(json) else {
            return XCTFail("expected age_switch")
        }
        XCTAssertEqual(block.h, "Age")
        XCTAssertEqual(block.options.map(\.age), [.neo, .infant])
        XCTAssertEqual(block.options.map(\.label), ["0–28 d", "1–3 mo"])
        XCTAssertEqual(block.options.map(\.pathId), ["chol_0_3m_neo", "chol_0_3m_infant"])
    }

    func testAgeSwitchRejectsUnknownAge() {
        let json = #"{"t":"age_switch","options":[{"age":"toddler","label":"1–3 y","path_id":"p"}]}"#
        XCTAssertThrowsError(try decodeBlock(json))
    }

    func testAgeSwitchShowsFirstBranchUntilAnAgeIsChosen() throws {
        let json = #"""
        {"t":"age_switch","options":[
          {"age":"neo","label":"A","path_id":"p_neo"},
          {"age":"infant","label":"B","path_id":"p_infant"}]}
        """#
        guard case .ageSwitch(let block) = try decodeBlock(json) else {
            return XCTFail("expected age_switch")
        }
        XCTAssertEqual(block.option(for: nil)?.pathId, "p_neo")
        XCTAssertEqual(block.option(for: .infant)?.pathId, "p_infant")
        // An age chosen elsewhere on the card with no branch here falls back to the first.
        XCTAssertEqual(block.option(for: .teen)?.pathId, "p_neo")
    }

    func testWorkup() throws {
        let json = #"""
        {"t":"workup","h":"First contact","groups":[
          {"label":"Blood — today","items":["Fractionated bilirubin (total + conjugated)","GGT, ALT, AST, ALP","INR"]},
          {"label":"Imaging","items":["Fasting abdominal ultrasound with Doppler"]}]}
        """#
        guard case .workup(let block) = try decodeBlock(json) else {
            return XCTFail("expected workup")
        }
        XCTAssertEqual(block.h, "First contact")
        XCTAssertEqual(block.groups.map(\.label), ["Blood — today", "Imaging"])
        XCTAssertEqual(block.groups.map(\.items.count), [3, 1])
    }

    func testWorkupRequiresGroups() {
        XCTAssertThrowsError(try decodeBlock(#"{"t":"workup","h":"First contact"}"#))
    }

    private func sampleWorkup() throws -> WorkupBlock {
        let json = #"""
        {"t":"workup","groups":[
          {"label":"Blood","items":["Bilirubin","**INR**"]},
          {"label":"Urine","items":["Culture","Reducing substances"]},
          {"label":"Imaging","items":["Ultrasound"]}]}
        """#
        var workup: WorkupBlock?
        if case .workup(let block) = try decodeBlock(json) { workup = block }
        return try XCTUnwrap(workup, "expected workup")
    }

    func testWorkupCopiesEverythingWhenNothingIsTicked() throws {
        let text = try sampleWorkup().copyText()
        XCTAssertEqual(text, "Blood\n- Bilirubin\n- INR\n\nUrine\n- Culture\n- Reducing substances\n\nImaging\n- Ultrasound")
    }

    func testWorkupCopiesOnlyTickedItemsUnderTheirGroups() throws {
        let checked: Set<WorkupItemID> = [WorkupItemID(group: 0, item: 1), WorkupItemID(group: 2, item: 0)]
        // Urine has nothing ticked, so its label is left out too.
        XCTAssertEqual(try sampleWorkup().copyText(checked: checked), "Blood\n- INR\n\nImaging\n- Ultrasound")
    }

    func testWorkupCopiesOneGroupWithoutBlankLines() throws {
        let checked: Set<WorkupItemID> = [WorkupItemID(group: 1, item: 0), WorkupItemID(group: 1, item: 1)]
        XCTAssertEqual(try sampleWorkup().copyText(checked: checked), "Urine\n- Culture\n- Reducing substances")
    }

    func testWorkupCopyStripsPhoneMarkup() throws {
        let json = #"{"t":"workup","groups":[{"label":"Calls","items":["Poison center [m]1-800-222-1222[/m]"]}]}"#
        guard case .workup(let block) = try decodeBlock(json) else {
            return XCTFail("expected workup")
        }
        XCTAssertEqual(block.copyText(), "Calls\n- Poison center 1-800-222-1222")
    }

    func testUnknownBlockTypeThrows() {
        XCTAssertThrowsError(try decodeBlock(#"{"t":"sep2col"}"#))
    }
}
