import XCTest
@testable import HepReference

final class PathwayNodeDecodingTests: XCTestCase {
    private func decodeNode(_ json: String) throws -> PathwayNode {
        try JSONDecoder().decode(PathwayNode.self, from: Data(json.utf8))
    }

    func testSection() throws {
        guard case .section(let heading, let children) = try decodeNode(#"{"t":"section","h":"Workup","children":[{"t":"row","text":"a"}]}"#) else {
            return XCTFail("expected section")
        }
        XCTAssertEqual(heading, "Workup")
        XCTAssertEqual(children.count, 1)
    }

    func testBox() throws {
        guard case .box(let style, let children) = try decodeNode(#"{"t":"box","style":"crit","children":[]}"#) else {
            return XCTFail("expected box")
        }
        XCTAssertEqual(style, .crit)
        XCTAssertEqual(children.count, 0)
    }

    func testGroup() throws {
        guard case .group(let label, let children) = try decodeNode(#"{"t":"group","label":"do now","children":[{"t":"row","text":"a"}]}"#) else {
            return XCTFail("expected group")
        }
        XCTAssertEqual(label, "do now")
        XCTAssertEqual(children.count, 1)
    }

    func testArm() throws {
        guard case .arm(let kind, let tag, let rx, let children) = try decodeNode(#"{"t":"arm","kind":"sev","tag":"PALF","rx":"treat now","children":[]}"#) else {
            return XCTFail("expected arm")
        }
        XCTAssertEqual(kind, .sev)
        XCTAssertEqual(tag, "PALF")
        XCTAssertEqual(rx, "treat now")
        XCTAssertEqual(children.count, 0)
    }

    func testArmWithoutRx() throws {
        guard case .arm(_, _, let rx, _) = try decodeNode(#"{"t":"arm","kind":"mild","tag":"No Sx","children":[]}"#) else {
            return XCTFail("expected arm")
        }
        XCTAssertNil(rx)
    }

    func testOutWithPill() throws {
        guard case .out(let condition, let pills, let subtext, _, _, _) = try decodeNode(#"{"t":"out","cond":"US negative","pill":{"kind":"dc","text":"Discharge"}}"#) else {
            return XCTFail("expected out")
        }
        XCTAssertEqual(condition, "US negative")
        XCTAssertEqual(pills.count, 1)
        XCTAssertEqual(pills.first?.kind, .dc)
        XCTAssertEqual(pills.first?.text, "Discharge")
        XCTAssertNil(subtext)
    }

    func testOutWithSubtext() throws {
        guard case .out(_, let pills, let subtext, _, _, _) = try decodeNode(#"{"t":"out","cond":"Glucose","subtext":"POC now"}"#) else {
            return XCTFail("expected out")
        }
        XCTAssertTrue(pills.isEmpty)
        XCTAssertEqual(subtext, "POC now")
    }

    func testOutWithMultiplePills() throws {
        guard case .out(_, let pills, _, _, _, _) = try decodeNode(#"{"t":"out","cond":"Shared decision","pills":[{"kind":"floor","text":"Admit"},{"kind":"dc","text":"Home"}]}"#) else {
            return XCTFail("expected out")
        }
        XCTAssertEqual(pills.map(\.kind), [.floor, .dc])
        XCTAssertEqual(pills.map(\.text), ["Admit", "Home"])
    }

    func testNest() throws {
        guard case .nest(let children) = try decodeNode(#"{"t":"nest","children":[{"t":"row","text":"a"}]}"#) else {
            return XCTFail("expected nest")
        }
        XCTAssertEqual(children.count, 1)
    }

    func testRowWithLabel() throws {
        guard case .row(let label, let text, let bullet, _, _) = try decodeNode(#"{"t":"row","label":"OCT:","text":"optical coherence tomography"}"#) else {
            return XCTFail("expected row")
        }
        XCTAssertEqual(label, "OCT:")
        XCTAssertEqual(text, "optical coherence tomography")
        XCTAssertTrue(bullet)
    }

    func testRowWithoutLabel() throws {
        guard case .row(let label, _, _, _, _) = try decodeNode(#"{"t":"row","text":"plain fact"}"#) else {
            return XCTFail("expected row")
        }
        XCTAssertNil(label)
    }

    func testRowBulletOptOut() throws {
        guard case .row(_, _, let bullet, _, _) = try decodeNode(#"{"t":"row","text":"a lone callout","bullet":false}"#) else {
            return XCTFail("expected row")
        }
        XCTAssertFalse(bullet)
    }

    func testRowWithLink() throws {
        guard case .row(_, _, _, let linkCalcId, let linkLabel) = try decodeNode(#"{"t":"row","text":"Classify injury pattern","link_calc_id":"c_rratio","link_label":"R-ratio"}"#) else {
            return XCTFail("expected row")
        }
        XCTAssertEqual(linkCalcId, "c_rratio")
        XCTAssertEqual(linkLabel, "R-ratio")
    }

    func testCol() throws {
        guard case .col(let children) = try decodeNode(#"{"t":"col","children":[{"t":"row","text":"a"},{"t":"row","text":"b"}]}"#) else {
            return XCTFail("expected col")
        }
        XCTAssertEqual(children.count, 2)
    }

    func testTable() throws {
        guard case .table(let head, let rows) = try decodeNode(#"{"t":"table","head":["Glucose","Dextrose"],"rows":[["≥ 275","0%"]]}"#) else {
            return XCTFail("expected table")
        }
        XCTAssertEqual(head, ["Glucose", "Dextrose"])
        XCTAssertEqual(rows, [["≥ 275", "0%"]])
    }

    func testUnknownNodeTypeThrows() {
        XCTAssertThrowsError(try decodeNode(#"{"t":"bogus"}"#))
    }

    func testAllArmAndPillKindsHaveTiers() {
        for kind in [ArmKind.mild, .mod, .sev, .floor] {
            _ = kind.tier
        }
        for kind in [PillKind.dc, .step, .floor, .picu] {
            _ = kind.tier
        }
        for style in [BoxStyle.plain, .info, .warn, .crit] {
            _ = style.tier
        }
    }
}
