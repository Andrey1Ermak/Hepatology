import XCTest
@testable import HepReference

final class CardMarkupTests: XCTestCase {
    func testPhoneMarkupBecomesTelLink() {
        // Display text keeps the dashes; the tel: URL is stripped to a clean dialable number.
        let result = CardMarkup.attributedString("Call [m]864-9439[/m] now")
        let run = result.runs.first { $0.link != nil }
        XCTAssertEqual(run?.link, URL(string: "tel:8649439"))
        XCTAssertEqual(String(result.characters), "Call 864-9439 now")
    }

    func testMultiplePhoneTagsInOneString() {
        let result = CardMarkup.attributedString("[m]692-8437[/m] / [m]692-8123[/m]")
        let links = result.runs.compactMap(\.link)
        XCTAssertEqual(links, [URL(string: "tel:6928437"), URL(string: "tel:6928123")])
    }

    func testHashPrefixedExtensionKeepsHash() {
        // "#" is percent-encoded (tel:%236465) since a literal "#" would otherwise be parsed
        // as a URL fragment delimiter; Phone still dials the decoded "#6465" extension.
        let result = CardMarkup.attributedString("[m]#6465[/m]")
        let run = result.runs.first { $0.link != nil }
        XCTAssertEqual(run?.link, URL(string: "tel:%236465"))
    }

    func testBoldMarkdownIsApplied() {
        let result = CardMarkup.attributedString("**give** hydrocortisone")
        let boldRun = result.runs.first { $0.inlinePresentationIntent == .stronglyEmphasized }
        XCTAssertNotNil(boldRun)
        XCTAssertEqual(String(result.characters), "give hydrocortisone")
    }

    func testLiteralBracketTextIsNotTreatedAsALink() {
        let result = CardMarkup.attributedString("Critical Airway team to [unit] room X")
        XCTAssertEqual(String(result.characters), "Critical Airway team to [unit] room X")
        XCTAssertTrue(result.runs.allSatisfy { $0.link == nil })
    }
}
