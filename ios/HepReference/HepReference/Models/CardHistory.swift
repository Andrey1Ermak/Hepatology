import Foundation
import Observation

/// The fellow's favorite cards (star in the card header) and the last cards
/// opened, shown on Home. Stores card ids only — never anything about a
/// patient — in `UserDefaults`, the same store `@AppStorage` uses. One shared
/// instance lives in `ContentView`, so the star and Home stay in step.
@Observable
final class CardHistory {
    /// How many recently opened cards Home keeps.
    static let recentLimit = 10

    static let favoritesKey = "hep.favorites"
    static let recentsKey = "hep.recents"

    /// Favorite card ids, newest first.
    private(set) var favorites: [String]
    /// Recently opened card ids, newest first, at most `recentLimit`.
    private(set) var recents: [String]

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        favorites = Self.cleaned(defaults.stringArray(forKey: Self.favoritesKey) ?? [])
        recents = Array(Self.cleaned(defaults.stringArray(forKey: Self.recentsKey) ?? []).prefix(Self.recentLimit))
    }

    func isFavorite(_ id: String) -> Bool {
        favorites.contains(id)
    }

    /// Stars or unstars a card; a new favorite goes to the front.
    func toggleFavorite(_ id: String) {
        if let i = favorites.firstIndex(of: id) {
            favorites.remove(at: i)
        } else {
            favorites.insert(id, at: 0)
        }
        defaults.set(favorites, forKey: Self.favoritesKey)
    }

    /// Moves a just-opened card to the front of `recents`.
    func recordVisit(_ id: String) {
        // Back from a linked card or another tab: already first, no write.
        guard recents.first != id else { return }
        recents = Self.pushed(id, onto: recents, limit: Self.recentLimit)
        defaults.set(recents, forKey: Self.recentsKey)
    }

    /// `id` first, then `list` without it, cut to `limit`.
    static func pushed(_ id: String, onto list: [String], limit: Int) -> [String] {
        Array(([id] + list.filter { $0 != id }).prefix(limit))
    }

    /// Drops empty and repeated ids from stored values, keeping first-seen order.
    private static func cleaned(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        return ids.filter { !$0.isEmpty && seen.insert($0).inserted }
    }
}

extension CardLibrary {
    /// The cards for stored ids, in the same order, skipping ids with no
    /// bundled card (a card removed in a later build leaves no dead link).
    func cards(ids: [String]) -> [Card] {
        ids.compactMap { cardsByID[$0] }
    }
}
