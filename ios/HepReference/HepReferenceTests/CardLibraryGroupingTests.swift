import XCTest
@testable import HepReference

final class CardLibraryGroupingTests: XCTestCase {
    private func card(_ id: String, cat: CardCategory) -> Card {
        Card(id: id, title: id, code: "code", cat: cat, acu: .ref, done: nil, reviewed: nil, src: nil, tags: [], blocks: [])
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

    /// Section order follows `CardCategory.browseOrder`, not manifest order.
    func testSectionOrderFollowsBrowseOrderNotManifestOrder() {
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
}
