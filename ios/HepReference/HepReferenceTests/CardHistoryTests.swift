import XCTest
@testable import HepReference

final class CardHistoryTests: XCTestCase {
    private var suiteName = ""
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "CardHistoryTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testStartsEmpty() {
        let history = CardHistory(defaults: defaults)
        XCTAssertEqual(history.favorites, [])
        XCTAssertEqual(history.recents, [])
        XCTAssertFalse(history.isFavorite("chol_0_3m"))
    }

    func testToggleFavoriteAddsToFrontAndRemoves() {
        let history = CardHistory(defaults: defaults)
        history.toggleFavorite("chol_0_3m")
        history.toggleFavorite("ggt_isolated")
        XCTAssertEqual(history.favorites, ["ggt_isolated", "chol_0_3m"])
        XCTAssertTrue(history.isFavorite("chol_0_3m"))
        history.toggleFavorite("chol_0_3m")
        XCTAssertEqual(history.favorites, ["ggt_isolated"])
        XCTAssertFalse(history.isFavorite("chol_0_3m"))
    }

    func testRecentsNewestFirstWithoutRepeatsAndCapped() {
        let history = CardHistory(defaults: defaults)
        for i in 1...12 { history.recordVisit("card\(i)") }
        XCTAssertEqual(history.recents.count, CardHistory.recentLimit)
        XCTAssertEqual(history.recents.first, "card12")
        XCTAssertEqual(history.recents.last, "card3")
        history.recordVisit("card7")
        XCTAssertEqual(history.recents.first, "card7")
        XCTAssertEqual(history.recents.filter { $0 == "card7" }.count, 1)
        XCTAssertEqual(history.recents.count, CardHistory.recentLimit)
    }

    func testRevisitingFrontCardChangesNothing() {
        let history = CardHistory(defaults: defaults)
        history.recordVisit("a")
        history.recordVisit("b")
        history.recordVisit("b")
        XCTAssertEqual(history.recents, ["b", "a"])
    }

    func testUnstarringLastFavoriteSavesEmptyList() {
        let history = CardHistory(defaults: defaults)
        history.toggleFavorite("a")
        history.toggleFavorite("a")
        XCTAssertEqual(defaults.stringArray(forKey: CardHistory.favoritesKey), [])
        XCTAssertEqual(CardHistory(defaults: defaults).favorites, [])
    }

    func testPersistsAcrossInstances() {
        let first = CardHistory(defaults: defaults)
        first.toggleFavorite("neo_jaundice")
        first.recordVisit("unconj_bili")
        first.recordVisit("neo_jaundice")
        let second = CardHistory(defaults: defaults)
        XCTAssertEqual(second.favorites, ["neo_jaundice"])
        XCTAssertEqual(second.recents, ["neo_jaundice", "unconj_bili"])
    }

    func testStoredValuesAreCleanedOnLoad() {
        defaults.set(["a", "", "b", "a"], forKey: CardHistory.favoritesKey)
        defaults.set((1...15).map { "r\($0)" }, forKey: CardHistory.recentsKey)
        let history = CardHistory(defaults: defaults)
        XCTAssertEqual(history.favorites, ["a", "b"])
        XCTAssertEqual(history.recents.count, CardHistory.recentLimit)
        XCTAssertEqual(history.recents.first, "r1")
    }

    func testLibraryResolvesOnlyBundledCardsInOrder() {
        let library = CardLibrary()
        let cards = library.cards(ids: ["ggt_isolated", "no_such_card", "chol_0_3m"])
        XCTAssertEqual(cards.map(\.id), ["ggt_isolated", "chol_0_3m"])
    }
}
