import XCTest
@testable import HepReference

final class CardLibraryGroupingTests: XCTestCase {
    private func card(_ id: String, cat: CardCategory) -> Card {
        Card(id: id, title: id, code: "code", cat: cat, acu: .ref)
    }

    /// Same-category entries are merged wherever they sit in the manifest,
    /// not just contiguous runs.
    func testEntriesShareSameCategoryEvenWhenNonContiguous() {
        let manifest = [
            ManifestEntry(id: "alt_elevated", cat: .labs, section: "LABS"),
            ManifestEntry(id: "palf", cat: .acute, section: "ACUTE"),
            ManifestEntry(id: "ast_isolated", cat: .labs, section: "LABS"),
        ]
        let cardsByID = [
            "alt_elevated": card("alt_elevated", cat: .labs),
            "palf": card("palf", cat: .acute),
            "ast_isolated": card("ast_isolated", cat: .labs),
        ]

        let sections = CardLibrary.groupedSections(manifestEntries: manifest, cardsByID: cardsByID)

        XCTAssertEqual(sections.count, 2)
        let labs = sections.first { $0.section == CardCategory.labs.displayName }
        XCTAssertEqual(labs?.cards.map(\.id), ["alt_elevated", "ast_isolated"])
    }

    /// A manifest entry without a bundled card is skipped without hiding
    /// the rest of its category.
    func testCategoryAppearsEvenWhenOneOfItsCardsIsNotBundled() {
        let manifest = [
            ManifestEntry(id: "chol_3_12m", cat: .jaundice, section: "JAUNDICE"),
            ManifestEntry(id: "chol_0_3m", cat: .jaundice, section: "JAUNDICE"),
        ]
        let cardsByID = ["chol_0_3m": card("chol_0_3m", cat: .jaundice)]

        let sections = CardLibrary.groupedSections(manifestEntries: manifest, cardsByID: cardsByID)

        XCTAssertEqual(sections.map(\.section), [CardCategory.jaundice.displayName])
        XCTAssertEqual(sections.first?.cards.map(\.id), ["chol_0_3m"])
    }

    /// Section order follows `CardCategory.homeOrder`, not manifest order.
    func testSectionOrderFollowsHomeOrderNotManifestOrder() {
        let manifest = [
            ManifestEntry(id: "about", cat: .ref, section: "REFERENCE"),
            ManifestEntry(id: "chol_0_3m", cat: .jaundice, section: "JAUNDICE"),
        ]
        let cardsByID = [
            "about": card("about", cat: .ref),
            "chol_0_3m": card("chol_0_3m", cat: .jaundice),
        ]

        let sections = CardLibrary.groupedSections(manifestEntries: manifest, cardsByID: cardsByID)

        XCTAssertEqual(sections.map(\.section), [CardCategory.jaundice.displayName, CardCategory.ref.displayName])
    }

    // MARK: - Home screen (day 11)

    /// Reference never joins the problem grid: it is its own tile below.
    /// Empty categories produce no tile, and the grid keeps homeOrder.
    func testHomeSetsReferenceApartAndHidesEmptyCategories() {
        let manifest = [
            ManifestEntry(id: "about", cat: .ref, section: "REFERENCE"),
            ManifestEntry(id: "palf", cat: .acute, section: "ACUTE"),
            ManifestEntry(id: "chol_0_3m", cat: .jaundice, section: "JAUNDICE"),
            ManifestEntry(id: "liver_mass", cat: .mass, section: "MASS"),
        ]
        let cardsByID = [
            "about": card("about", cat: .ref),
            "palf": card("palf", cat: .acute),
            "chol_0_3m": card("chol_0_3m", cat: .jaundice),
        ]

        let home = CardLibrary.homeSections(
            from: CardLibrary.groupedSections(manifestEntries: manifest, cardsByID: cardsByID)
        )

        XCTAssertEqual(home.problems.map(\.category), [.jaundice, .acute])
        XCTAssertEqual(home.reference?.cards.map(\.id), ["about"])
    }

    /// With no reference card bundled there is no Reference tile at all.
    func testHomeHasNoReferenceTileWithoutReferenceCards() {
        let manifest = [ManifestEntry(id: "alt_elevated", cat: .labs, section: "LABS")]
        let cardsByID = ["alt_elevated": card("alt_elevated", cat: .labs)]

        let home = CardLibrary.homeSections(
            from: CardLibrary.groupedSections(manifestEntries: manifest, cardsByID: cardsByID)
        )

        XCTAssertEqual(home.problems.map(\.category), [.labs])
        XCTAssertNil(home.reference)
    }

    /// The bundled library: every available card sits behind exactly one
    /// home tile (home → tile → card), and no tile is empty.
    func testBundledHomeTilesCoverEveryCardExactlyOnce() {
        let library = CardLibrary()
        let home = library.homeSections
        let tiles = home.problems + (home.reference.map { [$0] } ?? [])

        XCTAssertFalse(tiles.contains { $0.cards.isEmpty })
        let tiled = tiles.flatMap { $0.cards.map(\.id) }
        XCTAssertEqual(tiled.sorted(), library.availableEntries.map(\.id).sorted())
        for tile in tiles {
            XCTAssertEqual(library.cards(in: tile.category).map(\.id), tile.cards.map(\.id))
        }
    }
}
