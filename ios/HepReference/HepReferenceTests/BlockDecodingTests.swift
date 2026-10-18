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
        let json = #"{"t":"chip_screen","calc_id":"dka","label":"Cerebral edema screen"}"#
        guard case .chipScreen(let block) = try decodeBlock(json) else {
            return XCTFail("expected chip_screen")
        }
        XCTAssertEqual(block.calcId, "dka")
        XCTAssertEqual(block.label, "Cerebral edema screen")
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

    func testUnknownBlockTypeThrows() {
        XCTAssertThrowsError(try decodeBlock(#"{"t":"sep2col"}"#))
    }
}
