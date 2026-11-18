import XCTest
@testable import HepReference

final class SearchMatcherTests: XCTestCase {
    private let synonyms = [
        "biliary atresia": ["BA", "kasai", "атрезия"],
        "imaging": ["US", "ultrasound"],
    ]

    private func card(_ id: String, title: String, tags: [String] = []) -> Card {
        Card(id: id, title: title, code: "", cat: .jaundice, acu: .urg, tags: tags, blocks: [])
    }

    func testNormalizeFoldsCaseAccentsAndSpaces() {
        XCTAssertEqual(SearchMatcher.normalize("  Biliary   ATRESIA "), "biliary atresia")
        XCTAssertEqual(SearchMatcher.normalize("Холестаз новорождённых"), SearchMatcher.normalize("холестаз новорожденных"))
        XCTAssertEqual(SearchMatcher.normalize("Cholestasis 0–3 Months"), "cholestasis 0 3 months")
        XCTAssertEqual(SearchMatcher.normalize("0-3"), "0 3")
        XCTAssertEqual(SearchMatcher.normalize("Crigler–Najjar"), SearchMatcher.normalize("crigler najjar"))
        XCTAssertEqual(SearchMatcher.normalize("Gilbert’s"), SearchMatcher.normalize("Gilbert's"))
        // "й" folds to "и" on both sides — queries and cards still meet.
        XCTAssertEqual(SearchMatcher.normalize("Найяр"), SearchMatcher.normalize("наияр"))
    }

    func testShortQueriesMatchWholeWordsOnly() {
        let cards = [card("a", title: "Phenobarbital", tags: ["how to use"]), card("b", title: "INR", tags: ["PT"])]
        XCTAssertTrue(SearchMatcher.search("ba", in: cards, synonyms: [:]).isEmpty)
        XCTAssertTrue(SearchMatcher.search("us", in: cards, synonyms: [:]).isEmpty)
        XCTAssertEqual(SearchMatcher.search("pt", in: cards, synonyms: [:]).map(\.id), ["b"])
        XCTAssertEqual(SearchMatcher.search("barb", in: cards, synonyms: [:]).map(\.id), ["a"])
    }

    func testAliasNamesItsCanonicalTerm() {
        XCTAssertEqual(SearchMatcher.terms(for: "BA", synonyms: synonyms), ["ba", "biliary atresia"])
        XCTAssertEqual(SearchMatcher.terms(for: "Атрезия", synonyms: synonyms), ["атрезия", "biliary atresia"])
        XCTAssertEqual(SearchMatcher.terms(for: "kas", synonyms: synonyms), ["kas", "biliary atresia"])
    }

    func testShortQueriesNeedAnExactAlias() {
        // "B" is a prefix of "BA" but too short to stand for it.
        XCTAssertEqual(SearchMatcher.terms(for: "b", synonyms: synonyms), ["b"])
        XCTAssertEqual(SearchMatcher.terms(for: "us", synonyms: synonyms), ["us", "imaging"])
        XCTAssertEqual(SearchMatcher.terms(for: "   ", synonyms: synonyms), [])
    }

    func testAliasesAreNotMatchedAgainstCards() {
        // "US" is an alias of imaging; "jaundice" must not match through it.
        let cards = [card("a", title: "Jaundice"), card("b", title: "Which Imaging When")]
        XCTAssertEqual(SearchMatcher.search("ultrasound", in: cards, synonyms: synonyms).map(\.id), ["b"])
        XCTAssertEqual(SearchMatcher.search("jaund", in: cards, synonyms: synonyms).map(\.id), ["a"])
    }

    func testDirectMatchStillWorksWithoutSynonyms() {
        let cards = [card("a", title: "Prolonged INR", tags: ["vitamin K"])]
        XCTAssertEqual(SearchMatcher.search("vitamin k", in: cards, synonyms: [:]).map(\.id), ["a"])
        XCTAssertTrue(SearchMatcher.search("", in: cards, synonyms: [:]).isEmpty)
    }

    /// Day 33 acceptance: the Russian word, the abbreviation and the eponym
    /// all find the infant cholestasis card in the bundled library.
    func testBundledSearchFindsAtresiaByAnyName() {
        let bundle = Bundle(for: SearchMatcherTests.self)
        let library = CardLibrary(bundle: bundle)
        let synonyms = Registry(bundle: bundle).synonyms
        XCTAssertFalse(synonyms.isEmpty, "bundled synonyms failed to load")
        for query in ["атрезия", "BA", "kasai", "Kasai", "билиарная атрезия"] {
            XCTAssertTrue(library.search(query, synonyms: synonyms).contains { $0.id == "chol_0_3m" },
                          "'\(query)' does not find chol_0_3m")
        }
        XCTAssertTrue(library.search("МНО", synonyms: synonyms).contains { $0.id == "inr_prolonged" })
        XCTAssertFalse(library.search("BA", synonyms: synonyms).contains { $0.id == "inr_prolonged" },
                       "'BA' must not match 'rebalanced'")
        XCTAssertTrue(library.search("0-3", synonyms: synonyms).contains { $0.id == "chol_0_3m" })
        XCTAssertTrue(library.search("crigler najjar", synonyms: synonyms).contains { $0.id == "unconj_bili" })
        XCTAssertTrue(library.search("нормы", synonyms: synonyms).contains { $0.id == "ref_norms" })
    }
}
