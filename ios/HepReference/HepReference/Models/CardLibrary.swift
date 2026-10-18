import Foundation
import Observation

/// Loads bundled manifest + card JSON at launch and exposes browse/search views
/// over whatever cards have been extracted so far. Cards present in
/// manifest.json but without a bundled Content/Cards/<id>.json (not yet
/// migrated from the web app) are simply absent from every view below.
@Observable
final class CardLibrary {
    private(set) var cardsByID: [String: Card] = [:]
    private(set) var manifestEntries: [ManifestEntry] = []

    init(bundle: Bundle = .main) {
        manifestEntries = Self.loadManifest(bundle: bundle)
        cardsByID = Self.loadCards(ids: manifestEntries.map(\.id), bundle: bundle)
    }

    private static func loadManifest(bundle: Bundle) -> [ManifestEntry] {
        guard let url = bundle.url(forResource: "manifest", withExtension: "json", subdirectory: "Content"),
              let data = try? Data(contentsOf: url),
              let entries = try? Manifest.decode(from: data)
        else { return [] }
        return entries
    }

    private static func loadCards(ids: [String], bundle: Bundle) -> [String: Card] {
        var result: [String: Card] = [:]
        for id in ids {
            guard let url = bundle.url(forResource: id, withExtension: "json", subdirectory: "Content/Cards"),
                  let data = try? Data(contentsOf: url),
                  let card = try? JSONDecoder().decode(Card.self, from: data)
            else { continue }
            result[id] = card
        }
        return result
    }

    /// Manifest entries whose card JSON is bundled, in manifest order.
    var availableEntries: [ManifestEntry] {
        manifestEntries.filter { cardsByID[$0.id] != nil }
    }

    /// Browse sections, grouped by each card's `cat` (not `manifest.json`'s
    /// free-text `section` field, which produced 39 near-singleton sections
    /// for 78 cards) and ordered by `CardCategory.browseOrder`. `.ref` cards
    /// form their own "Reference" section like any other category — there is
    /// no separate Quick Reference carve-out.
    var groupedSections: [(section: String, cards: [Card])] {
        Self.groupedSections(manifestEntries: manifestEntries, cardsByID: cardsByID)
    }

    /// Groups from the *full* manifest, not just entries with a bundled card —
    /// a category's cards live wherever they sit in the manifest, so if an
    /// early entry isn't extracted yet, skipping it first would just leave a
    /// gap rather than mis-grouping anything (unlike the old section-anchor
    /// scheme this replaces). Only after bucketing by category do we drop
    /// entries without bundled JSON.
    static func groupedSections(
        manifestEntries: [ManifestEntry], cardsByID: [String: Card]
    ) -> [(section: String, cards: [Card])] {
        var byCategory: [CardCategory: [Card]] = [:]
        for entry in manifestEntries {
            guard let card = cardsByID[entry.id] else { continue }
            byCategory[entry.cat, default: []].append(card)
        }
        return CardCategory.browseOrder.compactMap { cat in
            guard let cards = byCategory[cat], !cards.isEmpty else { return nil }
            return (section: cat.displayName, cards: cards)
        }
    }

    func search(_ query: String) -> [Card] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return availableEntries.compactMap { cardsByID[$0.id] }.filter { card in
            card.title.lowercased().contains(q)
                || card.code.lowercased().contains(q)
                || card.tags.contains { $0.lowercased().contains(q) }
        }
    }
}
