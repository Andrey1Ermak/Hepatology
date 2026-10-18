import XCTest
@testable import HepReference

/// The release gate for bundled content. Every file under Content/ must
/// decode, and every reference between files must resolve — a broken link
/// fails the build instead of silently rendering a placeholder. Extend this
/// file (never weaken it) as new link types are added.
final class ContentIntegrityTests: XCTestCase {
    private let bundle = Bundle(for: ContentIntegrityTests.self)

    private func jsonFiles(_ folder: String) -> [URL] {
        guard let dir = bundle.url(forResource: folder, withExtension: nil, subdirectory: "Content"),
              let urls = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        else { return [] }
        return urls.filter { $0.pathExtension == "json" }.sorted { $0.path < $1.path }
    }

    private func decode<T: Decodable>(_ type: T.Type, _ url: URL) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
        } catch {
            XCTFail("\(url.lastPathComponent) failed to decode as \(T.self): \(error)")
            throw error
        }
    }

    private func allCards() throws -> [Card] {
        try jsonFiles("Cards").map { try decode(Card.self, $0) }
    }

    // MARK: Decoding

    func testEveryFileDecodesAndIdMatchesFilename() throws {
        for url in jsonFiles("Cards") {
            XCTAssertEqual(try decode(Card.self, url).id, url.deletingPathExtension().lastPathComponent)
        }
        for url in jsonFiles("Pathways") {
            XCTAssertEqual(try decode(Pathway.self, url).id, url.deletingPathExtension().lastPathComponent)
        }
        for url in jsonFiles("Calculators") {
            let screen = try decode(ChipScreen.self, url)
            XCTAssertEqual(screen.id, url.deletingPathExtension().lastPathComponent)
            _ = screen.verdictRule // traps on an unregistered named rule_id
        }
        for url in jsonFiles("ScoreCalcs") {
            XCTAssertEqual(try decode(ScoreCalcSchema.self, url).id, url.deletingPathExtension().lastPathComponent)
        }
    }

    // MARK: Manifest

    func testManifestAndCardFilesMatchOneToOne() throws {
        let url = try XCTUnwrap(bundle.url(forResource: "manifest", withExtension: "json", subdirectory: "Content"))
        let entries = try Manifest.decode(from: Data(contentsOf: url))
        let manifestIDs = entries.map(\.id)
        XCTAssertEqual(Set(manifestIDs).count, manifestIDs.count, "duplicate id in manifest.json")

        let cards = Dictionary(uniqueKeysWithValues: try allCards().map { ($0.id, $0) })
        XCTAssertEqual(Set(manifestIDs), Set(cards.keys), "manifest.json and Content/Cards must list the same ids")
        for entry in entries {
            XCTAssertEqual(cards[entry.id]?.cat, entry.cat, "\(entry.id): manifest cat differs from card cat")
        }
    }

    // MARK: Links

    func testEveryBlockReferenceResolves() throws {
        for card in try allCards() {
            for block in card.blocks {
                switch block {
                case .pathway(let b):
                    XCTAssertNotNil(Pathway.load(pathId: b.pathId, bundle: bundle), "\(card.id): pathway '\(b.pathId)' missing")
                case .chipScreen(let b):
                    XCTAssertNotNil(ChipScreen.load(calcId: b.calcId, bundle: bundle), "\(card.id): chip_screen '\(b.calcId)' missing")
                case .scoreCalc(let b):
                    XCTAssertNotNil(ScoreCalcSchema.load(calcId: b.calcId, bundle: bundle), "\(card.id): score_calc '\(b.calcId)' missing")
                case .numericCalc(let b):
                    XCTAssertTrue(NumericCalcRegistry.ids.contains(b.calcId), "\(card.id): numeric_calc '\(b.calcId)' not in NumericCalcRegistry")
                default:
                    break
                }
            }
        }
    }

    func testEveryPathwayCalculatorLinkResolves() throws {
        func linkIDs(_ nodes: [PathwayNode]) -> [String] {
            nodes.flatMap { node -> [String] in
                switch node {
                case .section(_, let c), .box(_, let c), .group(_, let c), .arm(_, _, _, let c), .nest(let c), .col(let c):
                    return linkIDs(c)
                case .out(_, _, _, let id, _, _), .row(_, _, _, let id, _):
                    return id.map { [$0] } ?? []
                case .table:
                    return []
                }
            }
        }
        for url in jsonFiles("Pathways") {
            let pathway = try decode(Pathway.self, url)
            for id in linkIDs(pathway.children) {
                XCTAssertTrue(
                    NumericCalcRegistry.ids.contains(id) || ChipScreen.load(calcId: id, bundle: bundle) != nil,
                    "\(pathway.id): link_calc_id '\(id)' resolves to no calculator"
                )
            }
        }
    }

    // MARK: Presentation

    func testEveryGridTitleFitsTheBrowseTile() throws {
        for card in try allCards() {
            XCTAssertLessThanOrEqual(card.gridTitle.count, 25, "\(card.id): add a gridTitleOverrides entry")
        }
    }
}
