import Foundation

/// Card search with the synonym registry (`Content/Registry/synonyms.json`).
///
/// A synonym entry maps a canonical term — a phrase that appears in some
/// card's title, code or tags — to the other ways a fellow may type it:
/// abbreviations ("BA"), eponyms ("kasai"), Russian words ("атрезия").
/// A query that names an alias pulls in its canonical term, so "BA" finds
/// every card tagged "biliary atresia". Aliases are never matched against
/// cards directly: short ones like "BA" or "US" would hit unrelated words.
/// One alias may sit under several terms ("pale stool" → neonatal jaundice
/// and neonatal cholestasis); the query then pulls in all of them.
enum SearchMatcher {
    /// Lowercased, accent- and width-folded, with punctuation, hyphens and
    /// dashes read as spaces ("0-3" = "0–3", "Crigler–Najjar" = "crigler
    /// najjar") and runs of spaces collapsed. Folding also turns "ё" into
    /// "е" and "й" into "и" — harmless, because queries and cards are
    /// folded the same way; never fold only one side.
    static func normalize(_ text: String) -> String {
        let folded = text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
        let spaced = String(folded.unicodeScalars.map { scalar in
            CharacterSet.alphanumerics.contains(scalar) ? Character(scalar) : " "
        })
        return spaced.split(separator: " ").joined(separator: " ")
    }

    /// Shortest query that may match the *start* of an alias or the inside
    /// of a card's words. Shorter queries must equal an alias ("BA" yes,
    /// "B" no) and match cards only as whole words: "BA" must not find
    /// "phenobarbital", nor "US" find "how to use".
    static let minimumPrefixLength = 3

    /// The normalized query plus every canonical term it names, in a stable
    /// order (the query first, then terms sorted). Empty for a blank query.
    static func terms(for query: String, synonyms: [String: [String]]) -> [String] {
        let q = normalize(query)
        guard !q.isEmpty else { return [] }
        var terms = [q]
        for (canonical, aliases) in synonyms.sorted(by: { $0.key < $1.key }) {
            let names = [canonical] + aliases
            let named = names.contains { name in
                let n = normalize(name)
                return n == q || (q.count >= minimumPrefixLength && n.hasPrefix(q))
            }
            let term = normalize(canonical)
            if named, !terms.contains(term) { terms.append(term) }
        }
        return terms
    }

    /// Whether a card's title, code or one of its tags contains `term` (a
    /// normalized string) — anywhere for terms of `minimumPrefixLength` or
    /// more, as a whole word for shorter ones.
    static func card(_ card: Card, contains term: String) -> Bool {
        ([card.title, card.code] + card.tags).contains { field in
            let text = normalize(field)
            guard term.count < minimumPrefixLength else { return text.contains(term) }
            return (" " + text + " ").contains(" " + term + " ")
        }
    }

    /// Cards (in the given order) that match the query or a term it names.
    static func search(_ query: String, in cards: [Card], synonyms: [String: [String]]) -> [Card] {
        let terms = terms(for: query, synonyms: synonyms)
        guard !terms.isEmpty else { return [] }
        return cards.filter { card in terms.contains { self.card(card, contains: $0) } }
    }
}
